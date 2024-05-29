// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./MultiSignFactory.sol";
import "./ERC20Pot.sol";

contract Deployer1 {
    Validation immutable private _validation;
    Calculation immutable private _calculation;
    FilecoinAPI immutable private _filecoinAPI;
    FILTrust immutable private _filTrust;
    FILGovernance immutable private _filGovernance;
    address immutable private _owner;

    MultiSignFactory immutable private _institutionSigner;
    ERC20Pot immutable private _institution;
    MultiSignFactory immutable private _teamSigner;
    ERC20Pot immutable private _team;
    MultiSignFactory immutable private _foundationSigner;
    ERC20Pot immutable private _foundation;
    MultiSignFactory immutable private _reserveSigner;
    ERC20Pot immutable private _reserve;
    MultiSignFactory immutable private _communitySigner;
    ERC20Pot immutable private _community;

    uint constant INSTITUTION_LOCKING_PERIOD = 1036800; //360 days
    uint constant TEAM_LOCKING_PERIOD = 3110400; //1080 days
    uint constant FOUNDATION_LOCKING_PERIOD = 3110400; //1080 days
    uint constant RESERVE_LOCKING_PERIOD = 1036800; //360 days
    uint constant COMMUNITY_LOCKING_PERIOD = 259200; //90 days

    uint constant INSTITUTION_SHARE = 250;
    uint constant TEAM_SHARE = 375;
    uint constant FOUNDATION_SHARE = 125;
    uint constant RESERVE_SHARE = 125;
    uint constant COMMUNITY_SHARE = 125;
    uint constant RATEBASE = 1000;

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
        _validation = new Validation();
        _calculation = new Calculation();
        _filecoinAPI = new FilecoinAPI();
        _filTrust = new FILTrust("FILLiquid Trust", "FIT");
        _filGovernance = new FILGovernance("FILLiquid Governance", "FIG");
        _owner = msg.sender;
        uint current = block.number;
        uint figBalance = _filGovernance.balanceOf(address(this));

        _institutionSigner = new MultiSignFactory(institutionSigners, institutionApprovalThreshold);
        _institution = new ERC20Pot(address(_institutionSigner), _filGovernance, figBalance * INSTITUTION_SHARE / RATEBASE, current, current + INSTITUTION_LOCKING_PERIOD);

        _teamSigner = new MultiSignFactory(teamSigners, teamApprovalThreshold);
        _team = new ERC20Pot(address(_teamSigner), _filGovernance, figBalance * TEAM_SHARE / RATEBASE, current, current + TEAM_LOCKING_PERIOD);

        _foundationSigner = new MultiSignFactory(foundationSigners, foundationApprovalThreshold);
        _foundation = new ERC20Pot(address(_foundationSigner), _filGovernance, figBalance * FOUNDATION_SHARE / RATEBASE, current, current + FOUNDATION_LOCKING_PERIOD);

        _reserveSigner = new MultiSignFactory(reserveSigners, reserveApprovalThreshold);
        _reserve = new ERC20Pot(address(_reserveSigner), _filGovernance, figBalance * RESERVE_SHARE / RATEBASE, current, current + RESERVE_LOCKING_PERIOD);

        _communitySigner = new MultiSignFactory(communitySigners, communityApprovalThreshold);
        _community = new ERC20Pot(address(_communitySigner), _filGovernance, figBalance * COMMUNITY_SHARE / RATEBASE, current, current + COMMUNITY_LOCKING_PERIOD);

        _filGovernance.transfer(address(_institution), figBalance * INSTITUTION_SHARE / RATEBASE);
        _filGovernance.transfer(address(_team), figBalance * TEAM_SHARE / RATEBASE);
        _filGovernance.transfer(address(_foundation), figBalance * FOUNDATION_SHARE / RATEBASE);
        _filGovernance.transfer(address(_reserve), figBalance * RESERVE_SHARE / RATEBASE);
        _filGovernance.transfer(address(_community), figBalance * COMMUNITY_SHARE / RATEBASE);
    }

    function setting(address deployer2) external {
        require (msg.sender == _owner, "only owner allowed");
        _filTrust.setOwner(deployer2);
        _filGovernance.setOwner(deployer2);
    }

    function getAddrs1() external view returns (
        Validation,
        Calculation,
        FilecoinAPI,
        FILTrust,
        FILGovernance,
        address
    ) {
        return (
            _validation,
            _calculation,
            _filecoinAPI,
            _filTrust,
            _filGovernance,
            _owner
        );
    }

    function getAddrs2() external view returns (
        MultiSignFactory,
        ERC20Pot,
        MultiSignFactory,
        ERC20Pot,
        MultiSignFactory,
        ERC20Pot,
        MultiSignFactory,
        ERC20Pot,
        MultiSignFactory,
        ERC20Pot
    ) {
        return (
            _institutionSigner,
            _institution,
            _teamSigner,
            _team,
            _foundationSigner,
            _foundation,
            _reserveSigner,
            _reserve,
            _communitySigner,
            _community
        );
    }
}