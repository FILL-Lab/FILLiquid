// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./MultiSignFactory.sol";

contract DeployerFIGMultiSigner {
    address _owner;

    MultiSignFactory immutable private _institutionSigner;
    MultiSignFactory immutable private _teamSigner;
    MultiSignFactory immutable private _foundationSigner;
    MultiSignFactory immutable private _reserveSigner;
    MultiSignFactory immutable private _communitySigner;

    constructor(
        address[] memory institutionSigners,
        uint institutionApprovalThreshold,
        address[] memory teamSigners,
        uint teamApprovalThreshold,
        address[] memory foundationSigners,
        uint foundationApprovalThreshold,
        address[] memory reserveSigners,
        uint reserveApprovalThreshold,
        address[] memory communitySigners,
        uint communityApprovalThreshold
    ) {
        _owner = msg.sender;
        
        _institutionSigner = new MultiSignFactory(institutionSigners, institutionApprovalThreshold);

        _teamSigner = new MultiSignFactory(teamSigners, teamApprovalThreshold);

        _foundationSigner = new MultiSignFactory(foundationSigners, foundationApprovalThreshold);

        _reserveSigner = new MultiSignFactory(reserveSigners, reserveApprovalThreshold);

        _communitySigner = new MultiSignFactory(communitySigners, communityApprovalThreshold);
    }

    function getAddrs() external view returns (
        address,
        MultiSignFactory,
        MultiSignFactory,
        MultiSignFactory,
        MultiSignFactory,
        MultiSignFactory
    ) {
        return (
            _owner,
            _institutionSigner,
            _teamSigner,
            _foundationSigner,
            _reserveSigner,
            _communitySigner
        );
    }
}