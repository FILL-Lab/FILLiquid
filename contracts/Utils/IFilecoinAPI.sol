// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "filecoin-solidity-api/contracts/v0.8/MinerAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/PrecompilesAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/SendAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/utils/FilAddressIdConverter.sol";

import "./Conversion.sol";

interface IFilecoinAPI{
    function getAvailableBalance(uint64 actorId) external view returns (CommonTypes.BigInt memory);

    function getOwnerActorId(uint64 minerId) external view returns (uint64);

    function getPendingBeneficiaryId(uint64 minerId) external view returns (address, bool);

    function resolveEthAddress(address addr) external view returns (uint64);

    function changeBeneficiary(
        uint64 minerId,
        CommonTypes.FilAddress calldata beneficiary,
        CommonTypes.BigInt calldata quota,
        CommonTypes.ChainEpoch expiration
    ) external;

    function withdrawBalance(uint64 actorId, uint amount) external returns (uint);

    function send(uint64 actorId, uint amount) external;

    function getBeneficiary(uint64 minerId) external view returns (MinerTypes.GetBeneficiaryReturn memory);

    function getOwner(uint64 minerId) external view returns (MinerTypes.GetOwnerReturn memory);

    function toAddress(uint64 actorId) external view returns (address);
}