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
    MultiSignFactory immutable private _teamSigner;
    MultiSignFactory immutable private _foundationSigner;
    MultiSignFactory immutable private _reserveSigner;
    MultiSignFactory immutable private _communitySigner;

    // FIG ERC20Pot
    ERC20Pot immutable private _institutionPot;
    ERC20Pot immutable private _teamPot;
    ERC20Pot immutable private _foundationPot;
    ERC20Pot immutable private _reservePot;
    ERC20Pot immutable private _communityPot;

    // FIL fee receiver multisigner
    MultiSignFactory immutable private _feeReceiverSigner;
    // FILPot
    FILPot immutable private _feeReceiverPot;

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
        (_deployerFIGMutilSignerOwner, _institutionSigner, _teamSigner, _foundationSigner, _reserveSigner, _communitySigner) = deployerFIGMultiSigner.getAddrs();
        
        // ERC20Pot contracts addresses
        (_institutionPot, _teamPot, _foundationPot, _reservePot, _communityPot) = deployerFIG.getAddrs2();
        
        (_deployerFeeMultiSignerOwner, _feeReceiverSigner, _feeReceiverPot) = deployerFeeMultiSigner.getAddrs();

        _feeReceiverPot = new FILPot(address(_feeReceiverSigner));

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
        _filGovernance.addManager(address(_fitStake));
        _filGovernance.addManager(address(_governance));
        _filGovernance.setOwner(0x000000000000000000000000000000000000dEaD);
    }

    function configure_MIX() external payable {
        require(msg.sender == address(_deployerMix));
        _filTrust.addManager(address(_filLiquid));
        _filTrust.addManager(address(_fitStake));

        _filLiquid.deposit{value: msg.value}(msg.value);
        // TODO: replace msg.sender with the actual FIT receiver
        _filTrust.transfer(msg.sender, _filTrust.balanceOf(address(this)));

        _filTrust.setOwner(0x000000000000000000000000000000000000dEaD);
        _fitStake.setOwner(0x000000000000000000000000000000000000dEaD);
        _governance.setOwner(0x000000000000000000000000000000000000dEaD);
    }
}