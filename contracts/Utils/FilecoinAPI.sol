// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "filecoin-solidity-api/contracts/v0.8/AccountAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/MinerAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/PrecompilesAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/SendAPI.sol";

import "./Conversion.sol";
import "./FilAddress.sol";

library FilecoinAPI{
    using Conversion for *;

    string constant err = "Error";

    function getAvailableBalance(uint64 actorId) internal view returns (CommonTypes.BigInt memory) {
        (int256 exitCode, CommonTypes.BigInt memory result) = MinerAPI.getAvailableBalance(wrapId(actorId));
        require(exitCode == 0, err);
        return result;
    }

    function getBeneficiary(uint64 minerId) internal view returns (MinerTypes.GetBeneficiaryReturn memory) {
        (int256 exitCode, MinerTypes.GetBeneficiaryReturn memory result) = MinerAPI.getBeneficiary(wrapId(minerId));
        require(exitCode == 0, err);
        return result;
    }

    function getOwner(uint64 minerId) internal view returns (MinerTypes.GetOwnerReturn memory){
        (int256 exitCode, MinerTypes.GetOwnerReturn memory result) = MinerAPI.getOwner(wrapId(minerId));
        require(exitCode == 0, err);
        return result;
    }

    function getOwnerActorId(uint64 minerId) internal view returns (uint64) {
        return PrecompilesAPI.resolveAddress(getOwner(minerId).owner);
    }

    function getPendingBeneficiaryId(uint64 minerId) internal view returns (address, bool) {
        CommonTypes.FilAddress memory newBeneficiary = getBeneficiary(minerId).proposed.new_beneficiary;
        if (newBeneficiary.data.length == 0) return (address(0), false);
        else return (FilAddress.toAddress(PrecompilesAPI.resolveAddress(newBeneficiary)), true);
    }

    function resolveEthAddress(address addr) internal view returns (uint64) {
        return PrecompilesAPI.resolveEthAddress(addr);
    }

    function authenticateMessage(CommonTypes.FilAddress memory signer, bytes calldata signature, bytes memory message) internal view {
        int256 exitCode = AccountAPI.authenticateMessage(
            CommonTypes.FilActorId.wrap(PrecompilesAPI.resolveAddress(signer)),
            AccountTypes.AuthenticateMessageParams({
                signature: signature,
                message: message
            })
        );
        require(exitCode == 0, err);
    }

    function changeBeneficiary(
        uint64 minerId,
        CommonTypes.FilAddress memory beneficiary,
        CommonTypes.BigInt memory quota,
        CommonTypes.ChainEpoch expiration
    ) internal {
        int256 exitCode = MinerAPI.changeBeneficiary(
            wrapId(minerId),
            MinerTypes.ChangeBeneficiaryParams({
                new_beneficiary: beneficiary,
                new_quota: quota,
                new_expiration: expiration
            })
        );
        require(exitCode == 0, err);
    }

    function withdrawBalance(uint64 actorId, uint amount) internal returns (uint) {
        (int256 exitCode, CommonTypes.BigInt memory result) = MinerAPI.withdrawBalance(wrapId(actorId), amount.uint2BigInt());
        require(exitCode == 0, err);
        return result.bigInt2Uint();
    }

    function send(uint64 actorId, uint amount) internal {
        int256 exitCode = SendAPI.send(wrapId(actorId), amount);
        require(exitCode == 0, err);
    }

    function wrapId(uint64 actorId) private pure returns(CommonTypes.FilActorId) {
        return CommonTypes.FilActorId.wrap(actorId);
    }
}