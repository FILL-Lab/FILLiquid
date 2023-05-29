// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/AccountAPI.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/utils/FilAddresses.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/SendAPI.sol";
import { UD60x18, ud, intoUint256 } from "@prb/math/src/UD60x18.sol";
import "@openzeppelin/contracts/utils/Context.sol";

import "./Convertion.sol";
import "./FilAddress.sol";
import "./FilecoinAPI.sol";

contract Playground is Context {
    using Convertion for *;

    FilecoinAPI private _filecoinAPI;

    mapping (address => uint256) public receivedAmounts;
    uint public accumulatedAmount;

    constructor(address filecoinAPI) {
        _filecoinAPI = FilecoinAPI(filecoinAPI);
    }

    receive() external payable{
        receivedAmounts[_msgSender()] += msg.value;
        accumulatedAmount += msg.value;
    }

    function sendMoney(address account, uint amount) external {
        payable(account).transfer(amount);
    }
    
    function verifyMsg(uint64 signerID, bytes memory signature, bytes memory message) external {
        AccountAPI.authenticateMessage(
            CommonTypes.FilActorId.wrap(signerID),
            AccountTypes.AuthenticateMessageParams({
                signature: signature,
                message: message
            })
        );
    }

    struct BorrowInfo {
        uint256 id; // borrow id
        address account; //borrow account
        uint256 amount; //borrow amount
        bytes minerAddr; //miner
        uint256 interestRate; // interest rate
        uint256 borrowTime; // borrow time
        uint256 paybackTime; // payback time
        bool isPayback; // flag for status
    }
    mapping(bytes => BorrowInfo[]) private minerBorrows;
    mapping(uint=>bytes) private map1;
    bytes[] byteArray;

    event show(uint c);
    event show1(bytes c);
    event show2(int64 c);
    event show3(bool c);
    event show4(bytes32 c);

    function test(bytes memory input1, bytes memory input2, bytes memory input3) external {
        bytes memory m;
        require(m.length == 0, "error");
        map1[1] = input1;
        byteArray.push(input1);
        byteArray.push(input2);
        byteArray.push(input3);
        delete map1[1];
        byteArray[1] = byteArray[byteArray.length - 1];
        byteArray.pop();
        emit show(map1[1].length);
        emit show(byteArray.length);
    }
    
    bytes[] array1;
    uint[] array2;
    function test2(bytes memory input1, bytes memory input2) external {
        array1.push(input1);
        array1.push(input2);
        bytes[] memory marray1 = array1;
        emit show(marray1.length);
        for (uint i = 0; i < marray1.length; i++) {
            emit show1(marray1[i]);
        }

        array2.push(1);
        array2.push(2);
        uint[] memory marray2 = array2;
        emit show(marray2.length);
        for (uint i = 0; i < marray2.length; i++) {
            emit show(marray2[i]);
        }
    }

    function getOwner(uint64 minerID) external returns (bytes memory) {
        return MinerAPI.getOwner(CommonTypes.FilActorId.wrap(minerID)).owner.data;
    }

    function getPledgableBalance(uint64 minerID) external returns (uint pledgableBalance) {
        pledgableBalance = getAvailableBalance(minerID) + getVestingbalance(minerID);
        emit show(pledgableBalance);
    }

    function getAvailableBalance(uint64 actorId) public returns (uint availableBalance) {
        availableBalance = MinerAPI.getAvailableBalance(CommonTypes.FilActorId.wrap(actorId)).bigInt2Uint();
        emit show(availableBalance);
    }

    function getVestingbalance(uint64 minerID) public returns (uint vestingBalance) {
        MinerTypes.VestingFunds[] memory funds = MinerAPI.getVestingFunds(CommonTypes.FilActorId.wrap(minerID)).vesting_funds;
        for (uint i = 0; i < funds.length; i++) {
            vestingBalance += funds[i].amount.bigInt2Uint();
            emit show(vestingBalance);
        }
    }

    function getBalance(uint64 actorId) external {
        uint availableBalance = MinerAPI.getAvailableBalance(CommonTypes.FilActorId.wrap(actorId)).bigInt2Uint();
        emit show(availableBalance);
        MarketTypes.GetBalanceReturn memory balancePair = MarketAPI.getBalance(FilAddresses.fromActorID(actorId));
        emit show1(FilAddresses.fromActorID(actorId).data);
        emit show(balancePair.balance.bigInt2Uint());
        emit show(balancePair.locked.bigInt2Uint());
        emit show1(balancePair.balance.val);
        emit show1(balancePair.balance.val);
    }

    function getBalance1(uint64 actorId) external view returns (uint) {
        return FilAddress.toAddress(actorId).balance;
    }

    function get1111Vestingbalance(uint64 minerID) external returns (uint vestingBalance) {
        MinerTypes.VestingFunds[] memory funds = MinerAPI.getVestingFunds(CommonTypes.FilActorId.wrap(minerID)).vesting_funds;
        for (uint i = 0; i < funds.length; i++) {
            CommonTypes.BigInt memory tmp = funds[i].amount;
        }
    }

    function testConvertion(uint input) external pure returns (uint) {
        uint result = input.uint2BigInt().bigInt2Uint();
        assert(result == input);
        return result;
    }

    function testUD60x18Pow(uint base, uint exp) external pure returns (uint) {
        UD60x18 convertedBase = ud(base);
        UD60x18 convertedExp = ud(exp);
        return convertedBase.pow(convertedExp).intoUint256();
    }

    function testUD60x18(uint input) external pure returns (uint) {
        UD60x18 convertedInput = ud(input);
        convertedInput = convertedInput.pow(convertedInput);
        return convertedInput.intoUint256();
    }

    function calculateContractAddress(address sender, bytes1 nonce) external pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), sender, bytes1(nonce))))));
    }

    function testTransfer(uint64 id, uint256 amount) external {
        //SendAPI.send(CommonTypes.FilActorId.wrap(id), amount);
        bytes memory callcode = abi.encodeCall(FilecoinAPI.send, (id, amount));
        (bool success, ) = address(_filecoinAPI).delegatecall(callcode);
        assert(success);
    }

    function testWithdraw(uint64 id, uint256 amount) external {
        uint availableAmount = _filecoinAPI.getAvailableBalance(id).bigInt2Uint();
        uint actualAmount = amount;
        if (actualAmount > availableAmount) actualAmount = availableAmount;
        bytes memory callcode = abi.encodeCall(FilecoinAPI.withdrawBalance, (id, amount));
        (bool success, bytes memory data) = address(_filecoinAPI).delegatecall(callcode);
        assert(success);
        uint withDrawnAmount = uint(bytes32(data));
        assert(withDrawnAmount == actualAmount);
        emit show(withDrawnAmount);
        emit show(availableAmount);
    }

    function getBeneficiary(uint64 minerId) public {
        CommonTypes.FilAddress memory minerOwner = _filecoinAPI.getOwner(minerId).owner;
        CommonTypes.FilAddress memory beneficiary = _filecoinAPI.getBeneficiary(minerId).active.beneficiary;
        emit show1(minerOwner.data);
        emit show1(beneficiary.data);
        CommonTypes.FilActorId wrappedId = CommonTypes.FilActorId.wrap(minerId);
        MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = MinerAPI.getBeneficiary(wrappedId);
        bytes memory active = beneficiaryRet.active.beneficiary.data;
        emit show1(active);
        bytes memory proposed = beneficiaryRet.proposed.new_beneficiary.data;
        emit show1(proposed);
        uint new_quota = beneficiaryRet.proposed.new_quota.bigInt2Uint();
        emit show(new_quota);
        int64 new_expiration = CommonTypes.ChainEpoch.unwrap(beneficiaryRet.proposed.new_expiration);
        emit show2(new_expiration);
        bool approved_by_beneficiary = beneficiaryRet.proposed.approved_by_beneficiary;
        emit show3(approved_by_beneficiary);
        bool approved_by_nominee = beneficiaryRet.proposed.approved_by_nominee;
        emit show3(approved_by_nominee);
    }

    function confirmPendingBeneficiaryChangeFromOwner(uint64 minerId) external {
        /*CommonTypes.FilActorId wrappedId = CommonTypes.FilActorId.wrap(minerId);
        CommonTypes.FilAddress memory owner = MinerAPI.getOwner(wrappedId).owner;
        MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = MinerAPI.getBeneficiary(wrappedId);
        MinerTypes.PendingBeneficiaryChange memory proposedBeneficiaryRet = beneficiaryRet.proposed;
        CommonTypes.FilAddress memory currentBeneficiary = beneficiaryRet.active.beneficiary;
        require(uint256(keccak256(abi.encode(owner.data))) == uint256(keccak256(abi.encode(currentBeneficiary.data))), "current beneficiary is not owner");
        MinerAPI.changeBeneficiary(
            wrappedId,
            MinerTypes.ChangeBeneficiaryParams({
                new_beneficiary: proposedBeneficiaryRet.new_beneficiary,
                new_quota: proposedBeneficiaryRet.new_quota,
                new_expiration: proposedBeneficiaryRet.new_expiration
            })
        );*/
        MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = _filecoinAPI.getBeneficiary(minerId);
        MinerTypes.PendingBeneficiaryChange memory proposedBeneficiaryRet = beneficiaryRet.proposed;
        require(uint256(keccak256(abi.encode(_filecoinAPI.getOwner(minerId).owner.data))) == 
        uint256(keccak256(abi.encode(beneficiaryRet.active.beneficiary.data))), "Current beneficiary is not owner");
        bytes memory callcode = abi.encodeCall(FilecoinAPI.changeBeneficiary, (minerId, proposedBeneficiaryRet.new_beneficiary, proposedBeneficiaryRet.new_quota, proposedBeneficiaryRet.new_expiration));
        (bool success, ) = address(_filecoinAPI).delegatecall(callcode);
        assert(success);
    }

    function returnBeneficiary(uint64 minerId) external {
        CommonTypes.FilAddress memory minerOwner = _filecoinAPI.getOwner(minerId).owner;
        CommonTypes.FilAddress memory beneficiary = _filecoinAPI.getBeneficiary(minerId).active.beneficiary;
        if (uint(keccak256(abi.encode(beneficiary.data))) != uint(keccak256(abi.encode(minerOwner.data)))) {
            bytes memory callcode = abi.encodeCall(FilecoinAPI.changeBeneficiary, (minerId, minerOwner, CommonTypes.BigInt(hex"00", false), CommonTypes.ChainEpoch.wrap(0)));
            (bool success, ) = address(_filecoinAPI).delegatecall(callcode);
            assert(success);
        }
        emit show1(minerOwner.data);
        emit show1(abi.encode(minerOwner.data));
        emit show4(keccak256(abi.encode(minerOwner.data)));
        emit show(uint(keccak256(abi.encode(minerOwner.data))));
        emit show1(beneficiary.data);
        emit show1(abi.encode(beneficiary.data));
        emit show4(keccak256(abi.encode(beneficiary.data)));
        emit show(uint(keccak256(abi.encode(beneficiary.data))));
        /*CommonTypes.FilActorId wrappedId = CommonTypes.FilActorId.wrap(minerId);
        CommonTypes.FilAddress memory owner = MinerAPI.getOwner(
            wrappedId
        ).owner;
        bytes memory callcode = abi.encodeCall(FilecoinAPI.changeBeneficiary, (minerId, owner, CommonTypes.BigInt(hex"00", false), CommonTypes.ChainEpoch.wrap(0)));
        (bool success, ) = address(_filecoinAPI).delegatecall(callcode);
        assert(success);*/
        /*MinerAPI.changeBeneficiary(
            wrappedId,
            MinerTypes.ChangeBeneficiaryParams({
                new_beneficiary: owner,
                new_quota: CommonTypes.BigInt(hex"00", false),
                new_expiration: CommonTypes.ChainEpoch.wrap(0)
            })
        );*/
        /*if (
            uint(bytes32(beneficiary.data)) !=
            uint(bytes32(owner.data))
        ) {
            MinerAPI.changeBeneficiary(
                wrappedId,
                MinerTypes.ChangeBeneficiaryParams({
                    new_beneficiary: owner,
                    new_quota: CommonTypes.BigInt(hex"00", false),
                    new_expiration: CommonTypes.ChainEpoch.wrap(0)
                })
            );
        }*/
    }

    /*function testFilAddress2FilActorId(uint64 actorId) public pure returns (bytes memory, uint64) {
        CommonTypes.FilAddress memory addr = FilAddresses.fromActorID(actorId);
        CommonTypes.FilActorId id = addr.FilAddress2FilActorId();
        return (addr.data, CommonTypes.FilActorId.unwrap(id));
    }*/
}