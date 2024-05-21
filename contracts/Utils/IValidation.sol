// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IValidation {
    function validateOwner(
        uint64 minerID,
        bytes calldata signature,
        address sender
    ) external;

    function getSigningMsg(uint64 minerID) external view returns (bytes memory m);

    function getNonce(bytes calldata addr) external view returns (uint256);
}
