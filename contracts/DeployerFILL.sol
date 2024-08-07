// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./FITStake.sol";
import "./Governance.sol";
import "./FILLiquid.sol";
import "./FILPot.sol";
import "./ERC20Pot.sol";
import "./DataFetcher.sol";

import "./DeployerUtils.sol";
import "./DeployerMix.sol";
import "./DeployerFIG.sol";
import "./DeployerFeeMultiSigner.sol";
import "./DeployerFIGMultiSigner.sol";

contract DeployerFILL {
    address immutable private _owner;

    Validation immutable private _validation;
    Calculation immutable private _calculation;
    FilecoinAPI immutable private _filecoinAPI;
    
    FILTrust immutable private _filTrust;
    FITStake immutable private _fitStake;
    Governance immutable private _governance;
    FILLiquid immutable private _filLiquid;
    FILGovernance immutable private _filGovernance;


    DeployerUtils immutable private _deployerUtils;
    DeployerMix immutable private _deployerMix;
    DeployerFIG immutable private _deployerFIG;
    DeployerFIGMultiSigner immutable private _deployerFIGMultiSigner;
    DeployerFeeMultiSigner immutable private _deployerFeeMultiSigner;

    address immutable private _deployerUtilsOwner;
    address immutable private _deployerMixOwner;
    address immutable private _deployerFIGOwner;
    address immutable private _deployerFIGMutilSignerOwner;
    address immutable private _deployerFeeMultiSignerOwner;

    // FIG multisigner
    MultiSignFactory immutable private _institutionSigner;
    MultiSignFactory immutable private _team1Signer;
    MultiSignFactory immutable private _team2Signer;
    MultiSignFactory immutable private _foundationSigner;
    MultiSignFactory immutable private _reserveSigner;
    MultiSignFactory immutable private _communitySigner;

    // FIG ERC20Pot
    ERC20Pot immutable private _institutionPot;
    ERC20Pot immutable private _team1Pot;
    ERC20Pot immutable private _team2Pot;
    ERC20Pot immutable private _foundationPot;
    ERC20Pot immutable private _reservePot;
    ERC20Pot immutable private _communityPot;

    // FIL fee receiver multisigner
    MultiSignFactory immutable private _feeReceiverSigner;
    // FILPot
    FILPot immutable private _feeReceiverPot;

    bool private _configured_FIG;
    bool private _configured_MIX;


    constructor(
        DeployerUtils deployerUtils, 
        DeployerMix deployerMix, 
        DeployerFIG deployerFIG, 
        DeployerFIGMultiSigner deployerFIGMultiSigner,
        DeployerFeeMultiSigner deployerFeeMultiSigner
    ) {
        _owner = msg.sender;

        _deployerUtils = deployerUtils;
        _deployerMix = deployerMix;
        _deployerFIG = deployerFIG;
        _deployerFIGMultiSigner = deployerFIGMultiSigner;
        _deployerFeeMultiSigner = deployerFeeMultiSigner;

        // Utils contracts addresses
        (_validation, _calculation, _filecoinAPI, _deployerUtilsOwner) = deployerUtils.getAddrs();

        // FIT、 FITStake、 Governance contracts addresses
        (_filTrust, _fitStake, _governance, _deployerMixOwner) = deployerMix.getAddrs();

        // FIG contracts addresses
        (_filGovernance, _deployerFIGOwner) = deployerFIG.getAddrs1();

        // MultiSigner contracts addresses
        (_deployerFIGMutilSignerOwner, _institutionSigner, _team1Signer, _team2Signer, _foundationSigner, _reserveSigner, _communitySigner) = deployerFIGMultiSigner.getAddrs();
        
        // ERC20Pot contracts addresses
        (_institutionPot, _team1Pot, _team2Pot, _foundationPot, _reservePot, _communityPot) = deployerFIG.getAddrs2();
        
        (_deployerFeeMultiSignerOwner, _feeReceiverSigner, _feeReceiverPot) = deployerFeeMultiSigner.getAddrs();

        require(_owner == _deployerMixOwner, "owner mismatch 0");
        require(_deployerMixOwner == _deployerUtilsOwner, "owner mismatch1");
        require(_deployerUtilsOwner == _deployerFIGOwner, "owner mismatch2");
        require(_deployerFIGOwner == _deployerFIGMutilSignerOwner, "owner mismatch3");
        require(_deployerFIGMutilSignerOwner == _deployerFeeMultiSignerOwner, "owner mismatch4");
 
        _filLiquid = new FILLiquid(
            address(_filTrust),
            address(_validation),
            address(_calculation),
            address(_filecoinAPI),
            address(_fitStake),
            address(_governance),
            payable(_feeReceiverPot)
        );
        _filLiquid.setOwner(0x000000000000000000000000000000000000dEaD);
    }

    function configure_FIG() external {
        require(msg.sender == address(_deployerFIG));
        require(!_configured_FIG);
        _filGovernance.addManager(address(_fitStake));
        _filGovernance.addManager(address(_governance));
        _filGovernance.setOwner(0x000000000000000000000000000000000000dEaD);
        _configured_FIG = true;
    }

    function configure_MIX() external payable {
        require(msg.sender == address(_deployerMix));
        require(!_configured_MIX);
        // Configure fitStake
        _fitStake.setContractAddrs(
            address(_filLiquid),
            address(_governance),
            address(_filTrust),
            address(_calculation),
            address(_filGovernance)
        );
        _fitStake.setOwner(0x000000000000000000000000000000000000dEaD);

        // Configure governance
        _governance.setContractAddrs(
            address(_filLiquid),
            address(_fitStake),
            address(_filGovernance)
        );
        _governance.setOwner(0x000000000000000000000000000000000000dEaD);


        // Configure filTrust
        _filTrust.addManager(address(_filLiquid));
        _filTrust.addManager(address(_fitStake));
        _filTrust.setOwner(0x000000000000000000000000000000000000dEaD);

        _configured_MIX = true;
    }

    function getDeployerAddrsOwners() external view returns (
        address, address, address, address, address, address
    ) {
        return (
            _deployerUtilsOwner,
            _deployerMixOwner,
            _deployerFIGOwner,
            _deployerFIGMutilSignerOwner,
            _deployerFeeMultiSignerOwner,
            _owner
        );
    }

    function getDeployerAddrs() external view returns (
        address, address, address, address, address, address
    ) {
        return (
            address(_deployerUtils),
            address(_deployerMix),
            address(_deployerFIG),
            address(_deployerFIGMultiSigner),
            address(_deployerFeeMultiSigner),
            address(this)
        );
    }

    function getMultiSignerAddrs() external view returns (
        address, address, address, address, address, address, address
    ) {
        return (
            address(_institutionSigner),
            address(_team1Signer),
            address(_team2Signer),
            address(_foundationSigner),
            address(_reserveSigner),
            address(_communitySigner),
            address(_feeReceiverSigner)
        );
    }

    function getPotAddrs() external view returns (
        address, address, address, address, address, address, address
    ) {
        return (
            address(_institutionPot),
            address(_team1Pot),
            address(_team2Pot),
            address(_foundationPot),
            address(_reservePot),
            address(_communityPot),
            address(_feeReceiverPot)
        );
    }

    function getFILLAddrs() external view returns (
        address, address, address, address, address, address, address, address
    ) {
        return (
            address(_validation),
            address(_calculation),
            address(_filecoinAPI),
            address(_filTrust),
            address(_fitStake),
            address(_governance),
            address(_filLiquid),
            address(_filGovernance)
        );
    }

    function isReady() external view returns (bool) {
        return _configured_FIG && _configured_MIX;
    }
}