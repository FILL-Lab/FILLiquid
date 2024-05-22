// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILTrust.sol";
import "./FITStake.sol";
import "./Governance.sol";
import "./DeployerFILL.sol";


contract DeployerMix {
    address immutable private _owner;

    FILTrust immutable private _filTrust;
    FITStake immutable private _fitStake;
    Governance immutable private _governance;
    bool settingDone;

    constructor() {
        _owner = msg.sender;
        _filTrust = new FILTrust("FILLiquid Trust", "FIT");
        _fitStake = new FITStake();
        _governance = new Governance();
    }

    function setting(DeployerFILL deployerFILL) external payable {
        require(msg.sender == _owner, "DeployerFIG: FORBIDDEN");
        require(!settingDone, "DeployerFIG: SETTING DONE");
        settingDone = true;
        _filTrust.setOwner(address(deployerFILL));
        _fitStake.setOwner(address(deployerFILL));
        _governance.setOwner(address(deployerFILL));
        deployerFILL.configure_MIX{
            value: msg.value
        }();
    }

    function getAddrs() external view returns (FILTrust, FITStake, Governance, address) {
        return (
            _filTrust,
            _fitStake,
            _governance,
            _owner
        );
    }
}