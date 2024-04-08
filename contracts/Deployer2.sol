// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./Deployer1.sol";
import "./FITStake.sol";
import "./Governance.sol";
import "./FILLiquid.sol";
import "./MultiSignFactory.sol";

contract Deployer2 {
    FITStake private _fitStake;
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
            FILGovernance _filGovernance,,,
            address _ownerDeployer1
        ) = _deployer1.getAddrs();
        require (msg.sender == _ownerDeployer1, "only owner allowed");
        _owner = msg.sender;

        _fitStake = new FITStake();
        emit ContractPublishing("FITStake", address(_fitStake));
        _governance = new Governance();
        emit ContractPublishing("Governance", address(_governance));
        _filLiquid = new FILLiquid(
            address(_filTrust),
            address(_validation),
            address(_calculation),
            address(_filecoinAPI),
            address(_fitStake),
            address(_governance),
            payable(msg.sender)
        );
        emit ContractPublishing("FILLiquid", address(_filLiquid));

        _fitStake.setContractAddrs(
            address(_filLiquid),
            address(_governance),
            address(_filTrust),
            address(_calculation),
            address(_filGovernance)
        );
        _governance.setContractAddrs(
            address(_filLiquid),
            address(_fitStake),
            address(_filGovernance)
        );
    }

    function setting() external payable {
        require (msg.sender == _owner, "only owner allowed");
        (, , , FILTrust _filTrust, FILGovernance _filGovernance, , ,) = _deployer1.getAddrs();
        _filTrust.addManager(address(_filLiquid));
        _filTrust.addManager(address(_fitStake));
        _filLiquid.deposit{value: msg.value}(msg.value);
        uint filTrustBalance = _filTrust.balanceOf(address(this));
        assert(filTrustBalance == msg.value);
        _filTrust.transfer(msg.sender, filTrustBalance);
        
        _filGovernance.addManager(address(_fitStake));
        _filGovernance.addManager(address(_governance));

        _filTrust.setOwner(0x000000000000000000000000000000000000dEaD);
        _filGovernance.setOwner(0x000000000000000000000000000000000000dEaD);
        _fitStake.setOwner(0x000000000000000000000000000000000000dEaD);
        _governance.setOwner(0x000000000000000000000000000000000000dEaD);
        _filLiquid.setOwner(0x000000000000000000000000000000000000dEaD);
    }

    function getAddrs() external view returns (FITStake, Governance, FILLiquid, Deployer1, address) {
        return (
            _fitStake,
            _governance,
            _filLiquid,
            _deployer1,
            _owner
        );
    }
}