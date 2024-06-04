// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILGovernance.sol";
import "./MultiSignFactory.sol";
import "./ERC20Pot.sol";
import "./DeployerFILL.sol";
import "./DeployerFIGMultiSigner.sol";

// 该合约部署了FIG合约，并且根据MultiSigner分配初始代币
contract DeployerFIG {
    FILGovernance immutable private _filGovernance;
    address immutable private _owner;

    ERC20Pot immutable private _institution;
    ERC20Pot immutable private _team;
    ERC20Pot immutable private _foundation;
    ERC20Pot immutable private _reserve;
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

    bool settingDone;

    constructor(
        DeployerFIGMultiSigner deployerFIGMultiSigner
    ) {
        _owner = msg.sender;

        _filGovernance = new FILGovernance("FILLiquid Governance", "FIG");
        uint current = block.number;
        uint figBalance = _filGovernance.balanceOf(address(this));

        (, MultiSignFactory institutionSigner, MultiSignFactory teamSigner, MultiSignFactory foundationSigner, MultiSignFactory reserveSigner, MultiSignFactory communitySigner) = deployerFIGMultiSigner.getAddrs();
        
        _institution = new ERC20Pot(address(institutionSigner), _filGovernance, figBalance * INSTITUTION_SHARE / RATEBASE, current, current + INSTITUTION_LOCKING_PERIOD);
        _team = new ERC20Pot(address(teamSigner), _filGovernance, figBalance * TEAM_SHARE / RATEBASE, current, current + TEAM_LOCKING_PERIOD);
        _foundation = new ERC20Pot(address(foundationSigner), _filGovernance, figBalance * FOUNDATION_SHARE / RATEBASE, current, current + FOUNDATION_LOCKING_PERIOD);
        _reserve = new ERC20Pot(address(reserveSigner), _filGovernance, figBalance * RESERVE_SHARE / RATEBASE, current, current + RESERVE_LOCKING_PERIOD);
        _community = new ERC20Pot(address(communitySigner), _filGovernance, figBalance * COMMUNITY_SHARE / RATEBASE, current, current + COMMUNITY_LOCKING_PERIOD);
        _filGovernance.setOwner(tx.origin);
        _filGovernance.transfer(tx.origin, figBalance);
        // _filGovernance.transfer(address(_institution), figBalance * INSTITUTION_SHARE / RATEBASE);
        // _filGovernance.transfer(address(_team), figBalance * TEAM_SHARE / RATEBASE);
        // _filGovernance.transfer(address(_foundation), figBalance * FOUNDATION_SHARE / RATEBASE);
        // _filGovernance.transfer(address(_reserve), figBalance * RESERVE_SHARE / RATEBASE);
        // _filGovernance.transfer(address(_community), figBalance * COMMUNITY_SHARE / RATEBASE);
    }

    function setting(DeployerFILL deployerFILL) external {
        require(msg.sender == _owner, "DeployerFIG: FORBIDDEN");
        require(!settingDone, "DeployerFIG: SETTING DONE");
        settingDone = true;
        _filGovernance.setOwner(address(deployerFILL));
        deployerFILL.configure_FIG();
    }

    function getAddrs1() external view returns (
        FILGovernance,
        address
    ) {
        return (
            _filGovernance,
            _owner
        );
    }

    function getAddrs2() external view returns (
        ERC20Pot,
        ERC20Pot,
        ERC20Pot,
        ERC20Pot,
        ERC20Pot
    ) {
        return (
            _institution,
            _team,
            _foundation,
            _reserve,
            _community
        );
    }
}