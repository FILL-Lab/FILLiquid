// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./Deployer1.sol";
import "./Deployer3.sol";
import "./FILStake.sol";
import "./Governance.sol";
import "./FILLiquidData.sol";
import "./DataFetcher.sol";
import "./Utils/FilecoinAPI.sol";

contract Deployer4 {
    DataFetcher private _dataFetcher;
    Deployer3 private _deployer3;
    address private _owner;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor(address deployer3) {
        _deployer3 = Deployer3(deployer3);
        (
            FILStake _filStake,
            Governance _governance,
            FILLiquidData _filLiquidData,,
            Deployer1 _deployer1,,
            address _ownerDeployer2
        ) = _deployer3.getAddrs();
        (,FilecoinAPI _filecoinAPI, FILTrust _filTrust, FILGovernance _filGovernance,) = _deployer1.getAddrs();
        require (msg.sender == _ownerDeployer2, "only owner allowed");
        _owner = msg.sender;

        _dataFetcher = new DataFetcher(_filLiquidData, _filTrust, _filStake, _filGovernance, _governance, _filecoinAPI);
        emit ContractPublishing("DataFetcher", address(_dataFetcher));
    }

    function getAddrs() external view returns (DataFetcher, Deployer3, address) {
        return (
            _dataFetcher,
            _deployer3,
            _owner
        );
    }
}