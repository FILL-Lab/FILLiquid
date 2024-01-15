// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "filecoin-solidity-api/contracts/v0.8/MinerAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/PrecompilesAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/SendAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/utils/FilAddressIdConverter.sol";

import "./Conversion.sol";

contract FilecoinAPI{
    using Conversion for *;

    string constant err = "Error";

    function getAvailableBalance(uint64 actorId) external view returns (CommonTypes.BigInt memory) {
        (int256 exitCode, CommonTypes.BigInt memory result) = MinerAPI.getAvailableBalance(_wrapId(actorId));
        require(exitCode == 0, err);
        return result;
    }

    function getBeneficiary(uint64 minerId) public view returns (MinerTypes.GetBeneficiaryReturn memory) {
        (int256 exitCode, MinerTypes.GetBeneficiaryReturn memory result) = MinerAPI.getBeneficiary(_wrapId(minerId));
        require(exitCode == 0, err);
        return result;
    }

    function getOwner(uint64 minerId) public view returns (MinerTypes.GetOwnerReturn memory){
        (int256 exitCode, MinerTypes.GetOwnerReturn memory result) = MinerAPI.getOwner(_wrapId(minerId));
        require(exitCode == 0, err);
        return result;
    }

    function getOwnerActorId(uint64 minerId) external view returns (uint64) {
        return PrecompilesAPI.resolveAddress(getOwner(minerId).owner);
    }

    function getPendingBeneficiaryId(uint64 minerId) external view returns (address, bool) {
        CommonTypes.FilAddress memory newBeneficiary = getBeneficiary(minerId).proposed.new_beneficiary;
        if (newBeneficiary.data.length == 0) return (address(0), false);
        else return (toAddress(PrecompilesAPI.resolveAddress(newBeneficiary)), true);
    }

    function resolveEthAddress(address addr) external view returns (uint64) {
        return PrecompilesAPI.resolveEthAddress(addr);
    }

    function toAddress(uint64 actorId) public view returns (address) {
        return FilAddressIdConverter.toAddress(actorId);
    }

    function changeBeneficiary(
        uint64 minerId,
        CommonTypes.FilAddress memory beneficiary,
        CommonTypes.BigInt memory quota,
        CommonTypes.ChainEpoch expiration
    ) external {
        int256 exitCode = MinerAPI.changeBeneficiary(
            _wrapId(minerId),
            MinerTypes.ChangeBeneficiaryParams({
                new_beneficiary: beneficiary,
                new_quota: quota,
                new_expiration: expiration
            })
        );
        require(exitCode == 0, err);
    }

    function withdrawBalance(uint64 actorId, uint amount) external returns (uint) {
        (int256 exitCode, CommonTypes.BigInt memory result) = MinerAPI.withdrawBalance(_wrapId(actorId), amount.uint2BigInt());
        require(exitCode == 0, err);
        return result.bigInt2Uint();
    }

    function send(uint64 actorId, uint amount) external {
        int256 exitCode = SendAPI.send(_wrapId(actorId), amount);
        require(exitCode == 0, err);
    }

    function _wrapId(uint64 actorId) private pure returns(CommonTypes.FilActorId) {
        return CommonTypes.FilActorId.wrap(actorId);
    }
}