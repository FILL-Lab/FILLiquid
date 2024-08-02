// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquid.sol";

import "filecoin-solidity-api/contracts/v0.8/utils/FilAddressIdConverter.sol";

contract Static {
    
    FILLiquidInterface public _filliquid;

    constructor(address filliquid) {
        _filliquid = FILLiquidInterface(filliquid);
    }

    function getTVL() external view returns (uint minerNum, uint collaterizedMinerNum, uint totalLockedMinerBalance, uint totalFILLiquidity, uint availableFILLiquidity, uint tvl) {
        uint start = 0;
        uint end = _filliquid.allMinersCount();
        minerNum = end;

        FILLiquid.BindStatusInfo[] memory allMiners = _filliquid.allMinersSubset(start, end);
        for (uint j = 0; j < allMiners.length; j++) {
            FILLiquid.BindStatusInfo memory info = allMiners[j];
            if (!info.status.stillBound) continue;
            collaterizedMinerNum++;
            totalLockedMinerBalance += minerBalance(info.minerId);
        }

        FILLiquid.FILLiquidInfo memory filLiquidInfo = _filliquid.getStatus();
        totalFILLiquidity = filLiquidInfo.totalFIL;
        availableFILLiquidity = filLiquidInfo.availableFIL;
        tvl = totalLockedMinerBalance + availableFILLiquidity;
    }

    function minerBalance(uint64 minerId) internal view returns (uint) {
        return toAddress(minerId).balance;
    }
    
    function toAddress(uint64 actorId) internal view returns (address) {
        return FilAddressIdConverter.toAddress(actorId);
    }
}