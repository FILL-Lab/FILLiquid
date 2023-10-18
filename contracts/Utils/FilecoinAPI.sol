// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/MinerAPI.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/PrecompilesAPI.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/SendAPI.sol";

import "./Convertion.sol";

contract FilecoinAPI{
    using Convertion for *;
    // function getAvailableBalance(uint64 actorId) external returns (CommonTypes.BigInt memory){
    //     return MinerAPI.getAvailableBalance(wrapId(actorId));
    // }
    
    function getAvailableBalance(uint64 actorId) external returns (CommonTypes.BigInt memory){
        uint balance = uint(actorId) * 1e18 / 2;
        return balance.uint2BigInt();
        // return MinerAPI.getAvailableBalance(wrapId(actorId));
    }

    function getBeneficiary(uint64 minerId) external returns (MinerTypes.GetBeneficiaryReturn memory){
        return MinerAPI.getBeneficiary(wrapId(minerId));
    }

    function getOwner(uint64 minerId) external returns (MinerTypes.GetOwnerReturn memory){
        return MinerAPI.getOwner(wrapId(minerId));
    }

    function getOwnerActorId(uint64 minerId) external returns (uint64){
        return PrecompilesAPI.resolveAddress(MinerAPI.getOwner(wrapId(minerId)).owner);
    }

    function resolveEthAddress(address addr) external view returns (uint64){
        return PrecompilesAPI.resolveEthAddress(addr);
    }

    function changeBeneficiary(
        uint64 minerId,
        CommonTypes.FilAddress memory beneficiary,
        CommonTypes.BigInt memory quota,
        CommonTypes.ChainEpoch expiration
    ) external{
        MinerAPI.changeBeneficiary(
            wrapId(minerId),
            MinerTypes.ChangeBeneficiaryParams({
                new_beneficiary: beneficiary,
                new_quota: quota,
                new_expiration: expiration
            })
        );
    }

    function withdrawBalance(uint64 actorId, uint amount) external returns (uint){
        return MinerAPI.withdrawBalance(wrapId(actorId), amount.uint2BigInt()).bigInt2Uint();
    }

    function send(uint64 actorId, uint amount) external{
        SendAPI.send(wrapId(actorId), amount);
    }

    function wrapId(uint64 actorId) private pure returns(CommonTypes.FilActorId) {
        return CommonTypes.FilActorId.wrap(actorId);
    }
}