// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./MultiSignFactory.sol";
import "./FILPot.sol";

contract DeployerFeeMultiSigner {
    address _owner;
    
    MultiSignFactory immutable private _feeReceiverSigner;
    FILPot immutable private _feeReceiverPot;

    constructor(
        address[] memory feeReceiverSigners,
        uint feeReceiverApprovalThreshold
    ) {
        _owner = msg.sender;
        _feeReceiverSigner = new MultiSignFactory(feeReceiverSigners, feeReceiverApprovalThreshold);
        _feeReceiverPot = new FILPot(address(_feeReceiverSigner));
    }

    function getAddrs() external view returns (
        address,
        MultiSignFactory,
        FILPot
    ) {
        return (
            _owner,
            _feeReceiverSigner,
            _feeReceiverPot
        );
    }
}