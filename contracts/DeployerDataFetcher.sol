// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./FITStake.sol";
import "./Governance.sol";
import "./FILLiquid.sol";

import "./DataFetcher.sol";
import "./DeployerFILL.sol";


contract DeployerDataFetcher {
    DataFetcher immutable private _dataFetcher;

    constructor(
        DeployerFILL deployerFILL
    ) {
        (,, address filecoinAPI,address filTrust, address fitStake, address governance, address filLiquid, address filGovernance) = deployerFILL.getFILLAddrs();

        _dataFetcher = new DataFetcher(
            FILLiquid(filLiquid),
            FILTrust(filTrust),
            FITStake(fitStake),
            FILGovernance(filGovernance),
            Governance(governance),
            FilecoinAPI(filecoinAPI)
        ); 
    }

    function getAddr() external view returns (address) {
        return address(_dataFetcher);
    }
}