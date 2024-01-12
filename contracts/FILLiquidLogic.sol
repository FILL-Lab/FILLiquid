// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./Utils/Conversion.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilAddress.sol";
import "./Utils/FilecoinAPI.sol";
import "./Utils/Validation.sol";
import "./FILLiquidData.sol";
import "./FILLiquidPool.sol";
import "./FILTrust.sol";
import "./FILStake.sol";

interface FILLiquidLogicInterface {
    /// @dev deposit FIL to the contract, mint FILTrust
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @return amount actual FILTrust minted
    function deposit(uint exchangeRate) external payable returns (uint amount);

    /// @dev redeem FILTrust to the contract, withdraw FIL
    /// @param amountFILTrust the amount of FILTrust user would like to redeem
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @return amount actual FIL withdrawal
    /// @return fee fee deducted
    function redeem(uint amountFILTrust, uint exchangeRate) external returns (uint amount, uint fee);

    /// @dev borrow FIL from the contract
    /// @param minerId miner id
    /// @param amountFIL the amount of FIL user would like to borrow
    /// @param interestRate approximated interest rate at the point of request
    /// @return amount actual FIL borrowed
    /// @return fee fee deducted
    function borrow(uint64 minerId, uint amountFIL, uint interestRate) external returns (uint amount, uint fee);

    /// @dev payback principal and interest by self
    /// @param minerIdPayee miner id being paid
    /// @param minerIdPayer miner id paying
    /// @param withdrawAmount maximum withdrawal amount
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    /// @return withdrawn withdrawn FIL
    /// @return mintedFIG FIG minted
    function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint withdrawAmount) external payable returns (uint principal, uint interest, uint withdrawn, uint mintedFIG);

    /// @dev payback principal and interest by anyone
    /// @param minerId miner id
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    /// @return mintedFIG FIG minted
    function directPayback(uint64 minerId) external payable returns (uint principal, uint interest, uint mintedFIG);

    /// @dev liquidate process
    /// @param minerIdPayee miner id being paid
    /// @param minerIdPayer miner id paying
    /// @return result liquidating result
    function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) external returns (uint[4] memory result);

    /// @dev collateralizing miner : change beneficiary to contract , need owner for miner propose change beneficiary first
    /// @param minerId miner id
    /// @param signature miner signature
    function collateralizingMiner(uint64 minerId, bytes calldata signature) external;

    /// @dev uncollateralizing miner : change beneficiary back to miner owner, need payback all first
    /// @param minerId miner id
    function uncollateralizingMiner(uint64 minerId) external;

    /// @dev return FIL/FILTrust exchange rate: total amount of FIL liquidity divided by total amount of FILTrust outstanding
    function exchangeRate() external view returns (uint);

    /// @dev return borrowing interest rate: a mathematical function of utilizatonRate
    function interestRate() external view returns (uint);

    /// @dev Emitted when `account` deposits `amountFIL` and mints `amountFILTrust`
    event Deposit(address indexed account, uint amountFIL, uint amountFILTrust);

    /// @dev Emitted when `account` redeems `amountFILTrust` and withdraws `amountFIL`
    event Redeem(address indexed account, uint amountFILTrust, uint amountFIL, uint fee);

    /// @dev Emitted when collateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration` by `sender`
    event CollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint quota, uint64 expiration);

    /// @dev Emitted when uncollateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration` by `sender`
    event UncollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint quota, uint64 expiration);

    /// @dev Emitted when user `account` borrows `amountFIL` with `minerId`
    event Borrow(
        uint indexed borrowId,
        address indexed account,
        uint64 indexed minerId,
        uint amountFIL,
        uint fee,
        uint interestRate,
        uint initialTime
    );
    
    /// @dev Emitted when user `account` repays `principal` + `interest` FIL for `minerIdPayee`,
    /// with `withdrawn` withdrawn from `minerIdPayer` and `principal` + `interest` - `withdrawn` from `account` and `mintedFIG` FIG minted
    event Payback(
        address indexed account,
        uint64 indexed minerIdPayee,
        uint64 indexed minerIdPayer,
        uint principal,
        uint interest,
        uint withdrawn,
        uint mintedFIG
    );

    /// @dev Emitted when user `account` liquidate `principal + interest + reward + fee` FIL for `minerId`
    event Liquidate(
        address indexed account,
        uint64 indexed minerIdPayee,
        uint64 indexed minerIdPayer,
        uint principal,
        uint interest,
        uint reward,
        uint fee
    );

    /// @dev Emitted when Borrow with `id` is updated
    event BorrowUpdated(
        uint indexed borrowId,
        uint borrowAmount,
        uint remainingOriginalAmount,
        uint datedTime
    );

    /// @dev Emitted when Borrow with `id` is droped
    event BorrowDropped(
        uint indexed id
    );
}

contract FILLiquidLogic is Context, FILLiquidLogicInterface {
    using Conversion for *;
    struct Response {
        uint amount;
        bool tag;
        string reason;
    }

    //administrative factors
    address private _owner;
    FILLiquidData private _data;
    FILLiquidPool private _pool;

    constructor(address filLiquidDataAddr, address payable filLiquidPoolAddr) {
        _owner = _msgSender();
        _data = FILLiquidData(filLiquidDataAddr);
        _pool = FILLiquidPool(filLiquidPoolAddr);
    }

    function deposit(uint expectAmountFILTrust) external payable returns (uint) {
        uint amountFIL = msg.value;
        (,,,,uint minDepositAmount,,,,,) = _data.getComprehensiveFactors();
        require(amountFIL >= minDepositAmount, "Value too small");
        payable(_pool).transfer(amountFIL);
        uint amountFILTrust = getFitByDeposit(amountFIL);
        _isLower(expectAmountFILTrust, amountFILTrust);
        
        _data.recordDeposit(amountFIL, amountFILTrust);
        address sender = _msgSender();
        _data.mintFIT(sender, amountFILTrust);
        
        emit Deposit(sender, amountFIL, amountFILTrust);
        return amountFILTrust;
    }

    function redeem(uint amountFILTrust, uint expectAmountFIL) external returns (uint, uint) {
        uint amountFIL = getFilByRedeem(amountFILTrust);
        _isLower(expectAmountFIL, amountFIL);
        require(amountFIL < _data.availableFIL(), "Insufficient available FIL");

        (,uint redeemFeeRate,,,,,,,,) = _data.getComprehensiveFactors();
        uint[2] memory fees = _data.calculateFee(amountFIL, redeemFeeRate);
        _data.recordRedeem(amountFILTrust, fees[0], fees[1]);
        address sender = _msgSender();
        _data.burnFIT(sender, amountFILTrust);
        if (amountFIL > 0) _pool.send(amountFIL);
        if (fees[1] > 0) _sendToFoundation(fees[1]);
        if (fees[0] > 0) payable(sender).transfer(fees[0]);

        emit Redeem(sender, amountFILTrust, fees[0], fees[1]);
        return (fees[0], fees[1]);
    }

    function borrow(uint64 minerId, uint amount, uint expectInterestRate) external isBindMiner(minerId) haveCollateralizing(minerId) returns (uint, uint) {
        Response memory response = getBorrowable(minerId, amount);
        require(response.tag, response.reason);
        uint realInterestRate = interestRateBorrow(amount);
        _isHigher(expectInterestRate, realInterestRate);

        uint borrowId = _data.getStatus().accumulatedBorrows;
        _updateBorrow(minerId, borrowId, amount, realInterestRate);

        (,,uint borrowFeeRate,,,,,,,) = _data.getComprehensiveFactors();
        uint[2] memory fees = _data.calculateFee(amount, borrowFeeRate);
        _data.recordBorrow(minerId, fees[0], fees[1]);
        FILLiquidDataInterface.MinerCollateralizingInfo memory info = _data.getCollateralizingMinerInfo(minerId);
        info.borrowAmount += amount;
        _data.updateCollateralizingMinerInfo(minerId, info);
        if (amount > 0) _pool.send(amount);
        if (fees[1] > 0) _sendToFoundation(fees[1]);
        if (fees[0] > 0) _send(minerId, fees[0]);

        emit Borrow(borrowId, _msgSender(), minerId, fees[0], fees[1], realInterestRate, block.timestamp);
        return (fees[0], fees[1]);
    }

    function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint amount) external isBindMiner(minerIdPayee) isSameFamily(minerIdPayee, minerIdPayer) isBorrower(minerIdPayee) payable returns (uint, uint, uint, uint) {
        Response memory response = _getAvailable(minerIdPayer);
        require(!response.tag, response.reason);
        if (amount > response.amount) {
            amount = response.amount;
        }
        uint[3] memory r = _paybackProcess(minerIdPayee, msg.value + amount);
        uint[2] memory sentBack_withdrawn;
        if (r[0] > amount) {
            sentBack_withdrawn[0] = r[0] - amount;
            payable(_msgSender()).transfer(sentBack_withdrawn[0]);
        } else if (r[0] < amount) {
            sentBack_withdrawn[1] = amount - r[0];
            _pool.withdrawBalance(minerIdPayer, sentBack_withdrawn[1]);
        }
        uint mintedFIG = _data.handleInterest(_msgSender(), r[1], r[2]);

        emit Payback(_msgSender(), minerIdPayee, minerIdPayer, r[1], r[2], sentBack_withdrawn[1], mintedFIG);
        return (r[1], r[2], sentBack_withdrawn[1], mintedFIG);
    }

    function directPayback(uint64 minerId) external isBorrower(minerId) payable returns (uint, uint, uint) {
        uint[3] memory r = _paybackProcess(minerId, msg.value);
        address sender = _msgSender();
        if (r[0] > 0) payable(sender).transfer(r[0]);
        uint mintedFIG = _data.handleInterest(_data.minerUser(minerId), r[1], r[2]);
        emit Payback(sender, minerId, minerId, r[1], r[2], 0, mintedFIG);
        return (r[1], r[2], mintedFIG);
    }

    function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) external isSameFamily(minerIdPayee, minerIdPayer) isBorrower(minerIdPayee) returns (uint[4] memory result) {
        Response memory response = getLiquidatable(minerIdPayee, minerIdPayer);
        require(response.tag, response.reason);

        // calculate the maximum amount for pinciple+interest
        uint[3] memory r = _paybackProcess(minerIdPayee, _data.getLiquidateAmount(response.amount));
 
        // calculate total withdraw, liquidate fee and reward
        uint totalWithdraw = _data.getWithDrawAmountFromLiquidate(r[1] + r[2]);
        (,,,,,uint liquidateFeeRate) = _data.getLiquidatingFactors();
        uint[2] memory fees = _data.calculateFee(totalWithdraw, liquidateFeeRate);
        uint bonus = fees[0] - (r[1] + r[2]);
        _updateLiquidate(minerIdPayee, totalWithdraw, bonus, fees[1]);

        if (totalWithdraw > 0) _pool.withdrawBalance(minerIdPayer, totalWithdraw);
        if (fees[1] > 0) _sendToFoundation(fees[1]);
        address sender = _msgSender();
        if (bonus > 0) payable(sender).transfer(bonus);
        result = [r[1], r[2], bonus, fees[1]];

        emit Liquidate(sender, minerIdPayee, minerIdPayer, r[1], r[2], bonus, fees[1]);
    }

    function collateralizingMiner(uint64 minerId, bytes calldata signature) external noCollateralizing(minerId) {
        address sender = _msgSender();
        (bool collateralizable, string memory reason) = getCollateralizable(minerId, sender);
        require(collateralizable, reason);
        
        if (sender != toAddress(FilecoinAPI.getOwnerActorId(minerId))) {
            (,,,,address validation,) = _data.getAdministrativeFactors();
            Validation(validation).validateOwner(minerId, signature, sender);
        }

        MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = FilecoinAPI.getBeneficiary(minerId);
        MinerTypes.PendingBeneficiaryChange memory proposedBeneficiaryRet = beneficiaryRet.proposed;
        require(uint(keccak256(abi.encode(FilecoinAPI.getOwner(minerId).owner.data))) == 
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
        _updatecollateralizingMiner(minerId, sender, uExpiration, quota);
        _data.recordCollateralizingMiner();

        emit CollateralizingMiner(
            minerId,
            sender,
            proposedBeneficiaryRet.new_beneficiary.data,
            quota,
            uExpiration
        );
    }

    function uncollateralizingMiner(uint64 minerId) external isBindMiner(minerId) haveCollateralizing(minerId) {
        address sender = _msgSender();
        (bool uncollateralizable, string memory reason) = getUncollateralizable(minerId, sender);
        require(uncollateralizable, reason);

        // change Beneficiary to owner
        bytes memory minerOwner = FilecoinAPI.getOwner(minerId).owner.data;
        _pool.changeBeneficiary(minerId, minerOwner, 0, 0);
        _data.deleteCollateralizingMinerInfo(minerId);
        _data.recordUncollateralizingMiner();

        //unbindMiner
        _data.updateMinerUser(minerId, address(0));
        _data.removeUserMiner(sender, minerId);
        _data.updateMinerStatus(minerId, FILLiquidDataInterface.BindStatus(true, false));

        emit UncollateralizingMiner(minerId, sender, minerOwner, 0, 0);
    }

    function changeBeneficiary(
        uint64 minerId,
        bytes calldata beneficiary,
        uint quota,
        int64 expiration
    ) onlyPool external {
        FilecoinAPI.changeBeneficiary(minerId, CommonTypes.FilAddress(beneficiary), quota.uint2BigInt(), CommonTypes.ChainEpoch.wrap(expiration));
    }

    function withdrawBalance(uint64 minerId, uint withdrawnAmount) onlyPool external {
        FilecoinAPI.withdrawBalance(minerId, withdrawnAmount);
    }

    function handleInterest(address minter, uint principal, uint interest) onlyData external returns (uint) {
        (,,,,,address filStake) = _data.getAdministrativeFactors();
         (bool success, bytes memory data) = filStake.call(
            abi.encodeWithSignature("handleInterest(address,uint256,uint256)", minter, principal, interest)
        );
        require(success, "HandleInterest failed");
        return uint(bytes32(data));
    }

    function mintFIT(address account, uint amount) onlyData external {
        (,,,address tokenFILTrust,,) = _data.getAdministrativeFactors();
        (bool success, ) = tokenFILTrust.call(
            abi.encodeWithSignature("mint(address,uint256)", account, amount)
        );
        require(success, "Mint failed");
    }

    function burnFIT(address account, uint amount) onlyData external {
        (,,,address tokenFILTrust,,) = _data.getAdministrativeFactors();
        (bool success, ) = tokenFILTrust.call(
            abi.encodeWithSignature("burn(address,uint256)", account, amount)
        );
        require(success, "Burn failed");
    }

    function getAvailableBalance(uint64 minerId) public view returns (uint, bool) {
        Conversion.Integer memory v = FilecoinAPI.getAvailableBalance(minerId).bigInt2Integer();
        return (v.value, v.neg);
    }

    function toAddress(uint64 minerId) public view returns (address) {
        return FilAddress.toAddress(minerId);
    }

    function getBorrowable(uint64 minerId) external view returns (Response memory) {
        (,,,,,uint minBorrowAmount,,,,) = _data.getComprehensiveFactors();
        return getBorrowable(minerId, minBorrowAmount);
    }

    function getBorrowable(uint64 minerId, uint amount) public view returns (Response memory) {
        uint64[] memory miners = _data.userMiners(_data.minerUser(minerId));
        (uint maxLiquidations,,,,,) = _data.getLiquidatingFactors();
        for (uint i = 0; i < miners.length; i++) {
            if (_data.liquidatedTimes(miners[i]) >= maxLiquidations) return Response(0, false, "Too many liquidations");
        }
        (,,,,,uint minBorrowAmount, uint maxExistingBorrows,,,) = _data.getComprehensiveFactors();
        if (_data.rawMinerBorrows(minerId).length >= maxExistingBorrows) return Response(0, false, "Too many borrows");
        Response memory response = _getAvailable(minerId);
        if (response.tag) return Response(0, false, response.reason);
        if (_data.badDebt(_data.minerUser(minerId)) != 0) return Response(0, false, "Family with bad debt");
        if (amount < minBorrowAmount) return Response(0, false, "Lower than minimum");
        if (amount > _data.maxBorrowAllowedByUtilization()) return Response(0, false, "Utilization would exceeds u_m");
        if (amount > _data.maxBorrowAllowed(minerId)) return Response(0, false, "Insufficient collateral");
        return Response(0, true, "");
    }

    function getLiquidatable(uint64 minerIdPayee, uint64 minerIdPayer) public view returns (Response memory) {
        uint lastLiquidate = _data.lastLiquidate(minerIdPayee);
        (,uint minLiquidateInterval,,,,) = _data.getLiquidatingFactors();
        if (lastLiquidate != 0 && block.timestamp - lastLiquidate < minLiquidateInterval) return Response(0, false, "Insufficient interval");
        if (!_data.liquidateCondition(_data.getFamilyStatus(_data.minerUser(minerIdPayee))).liquidatable) return Response(0, false, "Not liquidatable");
        Response memory response = _getAvailable(minerIdPayer);
        if (response.tag) return Response(0, false, response.reason);
        return Response(response.amount, true, "");
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
            balanceSum += toAddress(miners[i]).balance;
            principalAndInterestSum += _data.minerBorrows(miners[i]).debtOutStanding;
        }
        (uint rateBase,,,uint collateralRate,,,,,,) = _data.getComprehensiveFactors();
        if (collateralRate * balanceSum < rateBase * principalAndInterestSum) return (false, "Cannot exit family");
        return (true, "");
    }

    function exchangeRate() public view returns (uint) {
        (,,,address tokenFILTrust,,) = _data.getAdministrativeFactors();
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        return Calculation.getExchangeRate(_data.utilizationRate(), _data.getDepositRedeemFactors(), rateBase, FILTrust(tokenFILTrust).totalSupply(), _data.totalFILLiquidity());
    }

    function getFitByDeposit(uint amountFil) public view returns (uint) {
        (,,,address tokenFILTrust,,) = _data.getAdministrativeFactors();
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        return Calculation.getFitByDeposit(amountFil, _data.getDepositRedeemFactors(), rateBase, FILTrust(tokenFILTrust).totalSupply(), _data.totalFILLiquidity(), _data.utilizedLiquidity());
    }

    function getFilByRedeem(uint amountFit) public view returns (uint) {
        (,,,address tokenFILTrust,,) = _data.getAdministrativeFactors();
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        return Calculation.getFilByRedeem(amountFit, _data.getDepositRedeemFactors(), rateBase, FILTrust(tokenFILTrust).totalSupply(), _data.totalFILLiquidity(), _data.utilizedLiquidity());
    }

    function interestRate() public view returns (uint) {
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        (uint u_1, uint r_0, uint r_1,, uint n) = _data.getBorrowPayBackFactors();
        return Calculation.getInterestRate(_data.utilizationRate(), u_1, r_0, r_1, rateBase, n);
    }

    function interestRateBorrow(uint amount) public view returns (uint) {
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        (uint u_1, uint r_0, uint r_1,, uint n) = _data.getBorrowPayBackFactors();
        return Calculation.getInterestRate(_data.utilizationRateBorrow(amount), u_1, r_0, r_1, rateBase, n);
    }

    function paybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate) public view returns (uint) {
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        return Calculation.getPaybackAmount(borrowAmount, borrowPeriod, annualRate, rateBase);
    }

    function getN(uint u_1, uint u_m, uint r_1, uint r_m, uint rateBase) external pure returns (uint) {
        return Calculation.getN(u_1, u_m, r_1, r_m, rateBase);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function getAdministrativeFactors() external view returns (address, address) {
        return (address(_data), address(_pool));
    }

    function setAdministrativeFactors(
        address new_data,
        address payable new_pool
    ) onlyOwner external {
        _data = FILLiquidData(new_data);
        _pool = FILLiquidPool(new_pool);
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }

    modifier onlyData() {
        require(_msgSender() == address(_data), "Not data");
        _;
    }

    modifier onlyPool() {
        require(_msgSender() == address(_pool), "Not pool");
        _;
    }

    modifier isBindMiner(uint64 minerId) {
        require(_msgSender() == _data.minerUser(minerId), "Not bind");
        _;
    }

    modifier isSameFamily(uint64 minerIdPayee, uint64 minerIdPayer) {
        require(_data.minerUser(minerIdPayer) != address(0), "Not bind");
        require(_data.minerUser(minerIdPayer) == _data.minerUser(minerIdPayee), "Not same family");
        _;
    }

    modifier isBorrower(uint64 minerId) {
        require(_data.minerBorrowLength(minerId) != 0, "No borrow");
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

    function _getAvailable(uint64 minerId) public view returns (Response memory) {
        (uint available, bool neg) = getAvailableBalance(minerId);
        if (neg) return Response(0, neg, "Negtive available balance");
        else return Response(available, neg, "");
    }

    function _sendToFoundation(uint amount) private {
        (,,address payable foundation,,,) = _data.getAdministrativeFactors();
        foundation.transfer(amount);
    }

    function _send(uint64 actorId, uint amount) private {
        FilecoinAPI.send(actorId, amount);
    }

    function _isLower(uint expect, uint realtime) private pure {
        require(expect <= realtime, "Too high");
    }

    function _isHigher(uint expect, uint realtime) private pure {
        require(realtime <= expect, "Too low");
    }

    function _updateBorrow(uint64 minerId, uint borrowId, uint amount, uint realInterestRate) private {
        FILLiquidDataInterface.BorrowInfo[] memory prevBorrows = _data.rawMinerBorrows(minerId);
        FILLiquidDataInterface.BorrowInfo[] memory borrows = new FILLiquidDataInterface.BorrowInfo[](prevBorrows.length + 1);
        for (uint i = 0; i < prevBorrows.length; i++) {
            borrows[i] = prevBorrows[i];
        }
        borrows[prevBorrows.length] = FILLiquidDataInterface.BorrowInfo({
            id: borrowId,
            borrowAmount: amount,
            remainingOriginalAmount: amount,
            interestRate: realInterestRate,
            datedTime: block.timestamp,
            initialTime: block.timestamp
        });

        //sortMinerBorrows
        if (borrows.length >= 2) {
            FILLiquidDataInterface.BorrowInfo memory last = borrows[borrows.length - 1];
            uint index = 0;
            for (; index < borrows.length - 1; index++) {
                if (borrows[index].interestRate > last.interestRate) break;
            }
            for (uint i = borrows.length - 1; i > index; i--) {
                borrows[i] = borrows[i - 1];
            }
            borrows[index] = last;
        }
        _data.updateMinerBorrows(minerId, borrows);
    }

    function _updateLiquidate(uint64 minerIdPayee, uint totalWithdraw, uint bonus, uint fee) private {
        _data.recordLiquidate(bonus, fee);
        _data.updateLastLiquidate(minerIdPayee, block.timestamp);
        _data.updateLiquidatedTimes(minerIdPayee, _data.liquidatedTimes(minerIdPayee) + 1);
        FILLiquidDataInterface.MinerCollateralizingInfo memory info = _data.getCollateralizingMinerInfo(minerIdPayee);
        info.liquidatedAmount += totalWithdraw;
        _data.updateCollateralizingMinerInfo(minerIdPayee, info);
    }

    function _updatecollateralizingMiner(uint64 minerId, address sender, uint64 uExpiration, uint quota) private {
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

    function _paybackProcess(uint64 minerId, uint amount) private returns (uint[3] memory r) {
        r[0] = amount;
        FILLiquidDataInterface.BorrowInfo[] memory borrows = _data.rawMinerBorrows(minerId);
        uint len = borrows.length;
        for (uint i = len; i > 0; i--) {
            FILLiquidDataInterface.BorrowInfo memory info = borrows[i - 1];
            uint time = block.timestamp - info.datedTime;
            uint principalAndInterest = paybackAmount(info.borrowAmount, time, info.interestRate);
            uint payBackTotal;
            if (r[0] > principalAndInterest) {
                payBackTotal = principalAndInterest;
                r[0] -= principalAndInterest;
            } else {
                payBackTotal = r[0];
                r[0] = 0;
            }

            uint payBackInterest = principalAndInterest - info.remainingOriginalAmount;
            uint paybackPrincipal;
            if (payBackTotal < payBackInterest) {
                payBackInterest = payBackTotal;
                paybackPrincipal = 0;
            } else {
                paybackPrincipal = payBackTotal - payBackInterest;
            }
            r[2] += payBackInterest;
            r[1] += paybackPrincipal;
            if (principalAndInterest > payBackTotal){
                info.borrowAmount = principalAndInterest - payBackTotal;
                info.datedTime = block.timestamp;
                info.remainingOriginalAmount -= paybackPrincipal;
                emit BorrowUpdated(info.id, info.borrowAmount, info.remainingOriginalAmount, info.datedTime);
            } else {
                emit BorrowDropped(info.id);
                len--;
            }
            if (r[0] == 0) break;
        }
        FILLiquidDataInterface.BorrowInfo[] memory newBorrows = new FILLiquidDataInterface.BorrowInfo[](len);
        for (uint i = 0; i < len; i++) {
            newBorrows[i] = borrows[i];
        }
        _data.updateMinerBorrows(minerId, newBorrows);

        FILLiquidDataInterface.MinerCollateralizingInfo memory collateralizingInfo = _data.getCollateralizingMinerInfo(minerId);
        collateralizingInfo.borrowAmount -= r[1];
        _data.updateCollateralizingMinerInfo(minerId, collateralizingInfo);

        address user = _data.minerUser(minerId);
        uint accumulatedBadDebt = _data.getStatus().accumulatedBadDebt - _data.badDebt(user);
        uint balanceSum = 0;
        uint principleSum = 0;
        uint64[] memory miners = _data.userMiners(user);
        for (uint i = 0; i < miners.length; i++) {
            balanceSum += toAddress(miners[i]).balance;
            FILLiquidDataInterface.BorrowInfo[] memory borrowList = _data.rawMinerBorrows(miners[i]);
            for (uint j = 0; j < borrowList.length; j++) {
                principleSum += borrowList[j].remainingOriginalAmount;
            }
        }
        if (balanceSum == 0 || _data.badDebt(user) != 0) {
            _data.updateBadDebt(user, principleSum);
            accumulatedBadDebt += principleSum;
        }
        _data.recordPayback(minerId, r[1], r[2], accumulatedBadDebt);
    }
}
