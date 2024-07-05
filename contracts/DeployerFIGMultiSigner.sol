// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./MultiSignFactory.sol";

contract DeployerFIGMultiSigner {
    address _owner;

    MultiSignFactory immutable private _institutionSigner;
    MultiSignFactory immutable private _team1Signer;
    MultiSignFactory immutable private _team2Signer;
    MultiSignFactory immutable private _foundationSigner;
    MultiSignFactory immutable private _reserveSigner;
    MultiSignFactory immutable private _communitySigner;

    constructor(
        address[] memory institutionSigners,
        uint institutionApprovalThreshold,
        address[] memory team1Signers,
        uint team1ApprovalThreshold,
        address[] memory team2Signers,
        uint team2ApprovalThreshold,
        address[] memory foundationSigners,
        uint foundationApprovalThreshold,
        address[] memory reserveSigners,
        uint reserveApprovalThreshold,
        address[] memory communitySigners,
        uint communityApprovalThreshold
    ) {
        _owner = msg.sender;
        
        _institutionSigner = new MultiSignFactory(institutionSigners, institutionApprovalThreshold);

        _team1Signer = new MultiSignFactory(team1Signers, team1ApprovalThreshold);
        
        _team2Signer = new MultiSignFactory(team2Signers, team2ApprovalThreshold);

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
        MultiSignFactory,
        MultiSignFactory
    ) {
        return (
            _owner,
            _institutionSigner,
            _team1Signer,
            _team2Signer,
            _foundationSigner,
            _reserveSigner,
            _communitySigner
        );
    }
}