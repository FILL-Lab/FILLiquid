// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./Utils/Conversion.sol";
import "./Utils/FilecoinAPI.sol";
import "./Utils/Validation.sol";
import "./FILLiquidData.sol";
import "./FILLiquidPool.sol";

interface FILLiquidLogicCollateralizeInterface {
    /// @dev collateralizing miner : change beneficiary to contract , need owner for miner propose change beneficiary first
    /// @param minerId miner id
    /// @param signature miner signature
    function collateralizingMiner(uint64 minerId, bytes calldata signature) external;

    /// @dev uncollateralizing miner : change beneficiary back to miner owner, need payback all first
    /// @param minerId miner id
    function uncollateralizingMiner(uint64 minerId) external;

    /// @dev Emitted when collateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration` by `sender`
    event CollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint quota, uint64 expiration);

    /// @dev Emitted when uncollateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration` by `sender`
    event UncollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint quota, uint64 expiration);
}

contract FILLiquidLogicCollateralize is Context, FILLiquidLogicCollateralizeInterface {
    using Conversion for *;
    struct Response {
        uint amount;
        bool tag;
        string reason;
    }

    address private _owner;
    bool private _switch;

    //administrative factors
    FILLiquidData private _data;
    FILLiquidPool private _pool;
    FilecoinAPI private _filecoinAPI;
    Validation private _validation;

    constructor(address filLiquidDataAddr, address payable filLiquidPoolAddr, address filecoinAPIAddr, address validationAddr) {
        _owner = _msgSender();
        _data = FILLiquidData(filLiquidDataAddr);
        _pool = FILLiquidPool(filLiquidPoolAddr);
        _filecoinAPI = FilecoinAPI(filecoinAPIAddr);
        _validation = Validation(validationAddr);
        _switch = true;
    }

    function collateralizingMiner(uint64 minerId, bytes calldata signature) switchOn noCollateralizing(minerId) external {
        address sender = _msgSender();
        (bool collateralizable, string memory reason) = getCollateralizable(minerId, sender);
        require(collateralizable, reason);
        
        if (sender != _toAddress(_filecoinAPI.getOwnerActorId(minerId))) {
            _validation.validateOwner(minerId, signature, sender);
        }

        MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = _filecoinAPI.getBeneficiary(minerId);
        MinerTypes.PendingBeneficiaryChange memory proposedBeneficiaryRet = beneficiaryRet.proposed;
        require(uint(keccak256(abi.encode(_filecoinAPI.getOwner(minerId).owner.data))) == 
        uint(keccak256(abi.encode(beneficiaryRet.active.beneficiary.data))), "Beneficiary is not owner");
        
        // new_quota check
        uint quota = proposedBeneficiaryRet.new_quota.bigInt2Uint();
        (,,,,,,,,uint requiredQuota, int64 requiredExpiration) = _data.getComprehensiveFactors();
        require(quota == requiredQuota, "Invalid quota");
        int64 expiration = CommonTypes.ChainEpoch.unwrap(proposedBeneficiaryRet.new_expiration);
        uint64 uExpiration = uint64(expiration);
        require(expiration == requiredExpiration && uExpiration > block.number, "Invalid expiration");

        // change beneficiary to contract
        _pool.changeBeneficiary(minerId, proposedBeneficiaryRet.new_beneficiary.data, quota, CommonTypes.ChainEpoch.unwrap(proposedBeneficiaryRet.new_expiration));
        _updateCollateralizingMiner(minerId, sender, uExpiration, quota);
        _data.recordCollateralizingMiner();

        emit CollateralizingMiner(
            minerId,
            sender,
            proposedBeneficiaryRet.new_beneficiary.data,
            quota,
            uExpiration
        );
    }

    function uncollateralizingMiner(uint64 minerId) isBindMiner(minerId) haveCollateralizing(minerId) switchOn external {
        address sender = _msgSender();
        (bool uncollateralizable, string memory reason) = getUncollateralizable(minerId, sender);
        require(uncollateralizable, reason);

        // change Beneficiary to owner
        bytes memory minerOwner = _filecoinAPI.getOwner(minerId).owner.data;
        _pool.changeBeneficiary(minerId, minerOwner, 0, 0);
        _updateUncollateralizingMiner(minerId, sender);
        _data.recordUncollateralizingMiner();

        emit UncollateralizingMiner(minerId, sender, minerOwner, 0, 0);
    }

    function changeBeneficiary(
        uint64 minerId,
        bytes calldata beneficiary,
        uint quota,
        int64 expiration
    ) external {
        (bool success, ) = address(_filecoinAPI).delegatecall(
            abi.encodeCall(FilecoinAPI.changeBeneficiary, (minerId,CommonTypes.FilAddress(beneficiary), quota.uint2BigInt(), CommonTypes.ChainEpoch.wrap(expiration)))
        );
        require(success, "ChangeBeneficiary failed");
    }

    function getCollateralizable(uint64 minerId, address sender) public view returns (bool, string memory) {
        if (_data.minerUser(minerId) != address(0)) return (false, "Unbind first");
        (,,,,,,,uint maxFamilySize,,) = _data.getComprehensiveFactors();
        if (_data.userMiners(sender).length >= maxFamilySize) return (false, "Family size too big");
        return (true, "");
    }

    function getUncollateralizable(uint64 minerId, address sender) public view returns (bool, string memory) {
        if (_data.getCollateralizingMinerInfo(minerId).borrowAmount != 0) return (false, "Payback first");
        if (_data.badDebt(sender) != 0) return (false, "Family with bad debt");
        uint balanceSum = 0;
        uint principalAndInterestSum = 0;
        uint64[] memory miners = _data.userMiners(sender);
        for (uint i = 0; i < miners.length; i++) {
            if (miners[i] == minerId) continue;
            balanceSum += _toAddress(miners[i]).balance;
            principalAndInterestSum += _data.minerBorrows(miners[i]).debtOutStanding;
        }
        (uint rateBase,,,uint collateralRate,,,,,,) = _data.getComprehensiveFactors();
        if (collateralRate * balanceSum < rateBase * principalAndInterestSum) return (false, "Cannot exit family");
        return (true, "");
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function getAdministrativeFactors() external view returns (address, address, address, address) {
        return (address(_data), address(_pool), address(_filecoinAPI), address(_validation));
    }

    function setAdministrativeFactors(
        address new_data,
        address payable new_pool,
        address new_filecoinAPI,
        address new_validation
    ) onlyOwner external {
        _data = FILLiquidData(new_data);
        _pool = FILLiquidPool(new_pool);
        _filecoinAPI = FilecoinAPI(new_filecoinAPI);
        _validation = Validation(new_validation);
    }

    function getSwitch() external view returns (bool) {
        return _switch;
    }

    function turnSwitch(bool new_switch) onlyOwner external {
        _switch = new_switch;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }

    modifier isBindMiner(uint64 minerId) {
        require(_msgSender() == _data.minerUser(minerId), "Not bind");
        _;
    }

    modifier noCollateralizing(uint64 _id) {
        require(_data.getCollateralizingMinerInfo(_id).quota == 0, "Collateralized");
        _;
    }

    modifier haveCollateralizing(uint64 _id) {
        require(_data.getCollateralizingMinerInfo(_id).quota > 0, "Uncollateralized");
        _;
    }

    modifier switchOn() {
        require(_switch, "Switch is off");
        _;
    }
    
    function _updateCollateralizingMiner(uint64 minerId, address sender, uint64 uExpiration, uint quota) private {
        _data.updateMinerUser(minerId, sender);
        _data.addUserMiner(sender, minerId);
        if (!_data.minerStatus(minerId).onceBound) _data.pushAllMiners(minerId);
        _data.updateMinerStatus(minerId, FILLiquidDataInterface.BindStatus(true, true));
        _data.updateCollateralizingMinerInfo(minerId, FILLiquidDataInterface.MinerCollateralizingInfo({
            minerId: minerId,
            expiration: uExpiration,
            quota: quota,
            borrowAmount: 0,
            liquidatedAmount: 0
        }));
    }

    function _updateUncollateralizingMiner(uint64 minerId, address sender) private {
        _data.updateMinerUser(minerId, address(0));
        _data.removeUserMiner(sender, minerId);
        _data.updateMinerStatus(minerId, FILLiquidDataInterface.BindStatus(true, false));
        _data.deleteCollateralizingMinerInfo(minerId);
    }

    function _toAddress(uint64 minerId) private view returns (address) {
        return _filecoinAPI.toAddress(minerId);
    }
}
