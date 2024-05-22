// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILTrust.sol";
import "./FITStake.sol";
import "./Governance.sol";
import "./FILGovernance.sol";

interface IDeploy2 {
    function finalize() external payable;
}

contract Deployer1 {
    address _owner;

    address private _validation;
    address private _calculation;
    address private _filecoinAPI;

    FILTrust private _filTrust;
    FITStake private _fitStake;
    Governance private _governance;
    FILGovernance private _filGovernance;

    event ContractCreate(
        address contractAddr,
        string contractName
    );

    constructor(address validation, address calculation, address filecoinAPI) {
        _owner = msg.sender;
        _validation = validation;
        _calculation = calculation;
        _filecoinAPI = filecoinAPI;

        // 1. Create FILTrust 
        _filTrust = new FILTrust("FILTrust", "FIT");
        emit ContractCreate(address(_filTrust), "FILTrust");

        // 2. Create FITStake
        _fitStake = new FITStake();
        emit ContractCreate(address(_fitStake), "FITStake");

        // 3. Create Governance
        _governance = new Governance();
        emit ContractCreate(address(_governance), "Governance");

        // 4. Create FIGovernance
        _filGovernance = new FILGovernance("FILGovernance", "FIG");
        emit ContractCreate(address(_filGovernance), "FILGovernance");
    }

    function continueDeploy(address deployer2) external payable {
        require(msg.sender == _owner, "Deployer: only owner can continue deploy");
        // Only allow call once
        _owner = address(0);
        _filTrust.setOwner(deployer2);
        _fitStake.setOwner(deployer2);
        _governance.setOwner(deployer2);
        _filGovernance.setOwner(deployer2);
        
        IDeploy2 deploy2 = IDeploy2(deployer2);
        deploy2.finalize{value: msg.value}();
    }
}