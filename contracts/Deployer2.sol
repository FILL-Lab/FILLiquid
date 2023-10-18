// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./Deployer1.sol";
import "./FILStake.sol";
import "./Governance.sol";
import "./FILLiquid.sol";

contract Deployer2 {
    FILStake private _filStake;
    Governance private _governance;
    FILLiquid private _filLiquid;
    Deployer1 private _deployer1;
    address private _owner;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor(address deployer1) {
        _deployer1 = Deployer1(deployer1);
        (
            Validation _validation,
            Calculation _calculation,
            FilecoinAPI _filecoinAPI,
            FILTrust _filTrust,
            FILGovernance _filGovernance,
            address _ownerDeployer1
        ) = _deployer1.getAddrs();
        require (msg.sender == _ownerDeployer1, "only owner allowed");
        _owner = msg.sender;

        _filStake = new FILStake();
        emit ContractPublishing("FILStake", address(_filStake));
        _governance = new Governance();
        emit ContractPublishing("Governance", address(_governance));
        _filLiquid = new FILLiquid(
            address(_filTrust),
            address(_validation),
            address(_calculation),
            address(_filecoinAPI),
            address(_filStake),
            address(_governance),
            payable(msg.sender)
        );
        emit ContractPublishing("FILLiquid", address(_filLiquid));

        _filStake.setContactAddrs(
            address(_filLiquid),
            address(_governance),
            address(_filTrust),
            address(_calculation),
            address(_filGovernance)
        );
        _governance.setContactAddrs(
            address(_filLiquid),
            address(_filStake),
            address(_filGovernance)
        );
    }

    function setting() external payable {
        require (msg.sender == _owner, "only owner allowed");
        (, , , FILTrust _filTrust, FILGovernance _filGovernance,) = _deployer1.getAddrs();
        _filTrust.addManager(address(_filLiquid));
        _filTrust.addManager(address(_filStake));
        (uint rateBase,,,,,,,,,) = _filLiquid.getComprehensiveFactors();
        _filLiquid.deposit{value: msg.value}(rateBase);
        uint filTrustBalance = _filTrust.balanceOf(address(this));
        assert(filTrustBalance == msg.value);
        _filTrust.transfer(msg.sender, filTrustBalance);
        
        _filGovernance.addManager(address(_filStake));
        _filGovernance.addManager(address(_governance));

        _filTrust.setOwner(msg.sender);
        _filGovernance.setOwner(msg.sender);
        _filStake.setOwner(msg.sender);
        _governance.setOwner(msg.sender);
        _filLiquid.setOwner(msg.sender);
    }

    function getAddrs() external view returns (FILStake, Governance, FILLiquid, Deployer1, address) {
        return (
            _filStake,
            _governance,
            _filLiquid,
            _deployer1,
            _owner
        );
    }
}