// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquid.sol";

import "filecoin-solidity-api/contracts/v0.8/utils/FilAddressIdConverter.sol";

contract Static {
    
    FILLiquidInterface public _filliquid;

    struct TVLData {
        uint minerNum;                  // all miners in `fil-liquid` subset
        uint collaterizedMinerNum;      // miners still bound in `fil-liquid`
        uint totalLockedMinerBalance;   // total locked FIL balance of collaterized miners
        uint totalFILLiquidity;         // total FIL liquidity in `fil-liquid`
        uint availableFILLiquidity;     // available FIL liquidity in `fil-liquid`
        uint TVL;                       // the sum of `totalLockedMinerBalance` and `availableFILLiquidity`
    }

    constructor(address filliquid) {
        _filliquid = FILLiquidInterface(filliquid);
    }

    function getTVL() external view returns (TVLData memory data) {
        uint start = 0;
        uint end = _filliquid.allMinersCount();
        data.minerNum = end;

        FILLiquid.BindStatusInfo[] memory allMiners = _filliquid.allMinersSubset(start, end);
        for (uint j = 0; j < allMiners.length; j++) {
            FILLiquid.BindStatusInfo memory info = allMiners[j];
            if (!info.status.stillBound) continue;
            data.collaterizedMinerNum++;
            data.totalLockedMinerBalance += minerBalance(info.minerId);
        }

        FILLiquid.FILLiquidInfo memory filLiquidInfo = _filliquid.getStatus();
        data.totalFILLiquidity = filLiquidInfo.totalFIL;
        data.availableFILLiquidity = filLiquidInfo.availableFIL;
        data.TVL = data.totalLockedMinerBalance + data.availableFILLiquidity;
    }

    function minerBalance(uint64 minerId) internal view returns (uint) {
        return toAddress(minerId).balance;
    }
    
    function toAddress(uint64 actorId) internal view returns (address) {
        return FilAddressIdConverter.toAddress(actorId);
    }
}