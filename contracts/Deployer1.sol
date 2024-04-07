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
    Validation private _validation;
    Calculation private _calculation;
    FilecoinAPI private _filecoinAPI;
    FILTrust private _filTrust;
    FILGovernance private _filGovernance;
    MultiSignFactory private _multiSignFactory;
    ERC20Pot private _erc20Pot;
    address private _owner;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor(address[] memory signers, uint approvalThreshold, uint startHeight, uint totallyReleasedHeight) {
        _owner = msg.sender;
        _validation = new Validation();
        emit ContractPublishing("Validation", address(_validation));
        _calculation = new Calculation();
        emit ContractPublishing("Calculation", address(_calculation));
        _filecoinAPI = new FilecoinAPI();
        emit ContractPublishing("FilecoinAPI", address(_filecoinAPI));
        _filTrust = new FILTrust("FILTrust", "FIT");
        emit ContractPublishing("FILTrust", address(_filTrust));
        _filGovernance = new FILGovernance("FILGovernance", "FIG");
        emit ContractPublishing("FILGovernance", address(_filGovernance));
        _multiSignFactory = new MultiSignFactory(signers, approvalThreshold);
        emit ContractPublishing("MultiSignFactory", address(_multiSignFactory));
        uint figBalance = _filGovernance.balanceOf(address(this));
        _erc20Pot = new ERC20Pot(address(_multiSignFactory), _filGovernance, figBalance, startHeight, totallyReleasedHeight);
        emit ContractPublishing("ERC20Pot", address(_erc20Pot));
        _filGovernance.transfer(address(_erc20Pot), figBalance);
    }

    function setting(address deployer2) external {
        require (msg.sender == _owner, "only owner allowed");
        _filTrust.setOwner(deployer2);
        _filGovernance.setOwner(deployer2);
    }

    function getAddrs() external view returns (Validation, Calculation, FilecoinAPI, FILTrust, FILGovernance, MultiSignFactory, ERC20Pot, address) {
        return (
            _validation,
            _calculation,
            _filecoinAPI,
            _filTrust,
            _filGovernance,
            _multiSignFactory,
            _erc20Pot,
            _owner
        );
    }
}