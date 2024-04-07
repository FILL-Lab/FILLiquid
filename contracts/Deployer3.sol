// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./Deployer1.sol";
import "./Deployer2.sol";
import "./FITStake.sol";
import "./Governance.sol";
import "./FILLiquid.sol";
import "./DataFetcher.sol";
import "./Utils/FilecoinAPI.sol";

contract Deployer3 {
    DataFetcher private _dataFetcher;
    Deployer2 private _deployer2;
    address private _owner;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor(address deployer2) {
        _deployer2 = Deployer2(deployer2);
        (
            FITStake _fitStake,
            Governance _governance,
            FILLiquid _filLiquid,
            Deployer1 _deployer1,
            address _ownerDeployer2
        ) = _deployer2.getAddrs();
        (,,FilecoinAPI _filecoinAPI, FILTrust _filTrust, FILGovernance _filGovernance,,,) = _deployer1.getAddrs();
        require (msg.sender == _ownerDeployer2, "only owner allowed");
        _owner = msg.sender;

        _dataFetcher = new DataFetcher(_filLiquid, _filTrust, _fitStake, _filGovernance, _governance, _filecoinAPI);
        emit ContractPublishing("DataFetcher", address(_dataFetcher));
    }

    function getAddrs() external view returns (DataFetcher, Deployer2, address) {
        return (
            _dataFetcher,
            _deployer2,
            _owner
        );
    }
}