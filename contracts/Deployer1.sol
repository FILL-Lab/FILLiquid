// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILGovernance.sol";

contract Deployer1 {
    Validation private _validation;
    FilecoinAPI private _filecoinAPI;
    FILTrust private _filTrust;
    FILGovernance private _filGovernance;
    address private _owner;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor() {
        _owner = msg.sender;
        _validation = new Validation();
        emit ContractPublishing("Validation", address(_validation));
        _filecoinAPI = new FilecoinAPI();
        emit ContractPublishing("FilecoinAPI", address(_filecoinAPI));
        _filTrust = new FILTrust("FILTrust", "FIT");
        emit ContractPublishing("FILTrust", address(_filTrust));
        _filGovernance = new FILGovernance("FILGovernance", "FIG");
        emit ContractPublishing("FILGovernance", address(_filGovernance));
    }

    function setting(address deployer2) external {
        require (msg.sender == _owner, "only owner allowed");
        _filTrust.setOwner(deployer2);
        _filGovernance.setOwner(deployer2);
        _filGovernance.transfer(deployer2, _filGovernance.balanceOf(address(this)));
    }

    function getAddrs() external view returns (Validation, FilecoinAPI, FILTrust, FILGovernance, address) {
        return (
            _validation,
            _filecoinAPI,
            _filTrust,
            _filGovernance,
            _owner
        );
    }
}