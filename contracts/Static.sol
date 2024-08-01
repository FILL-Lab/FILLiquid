// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquid.sol";

import "filecoin-solidity-api/contracts/v0.8/utils/FilAddressIdConverter.sol";

contract Static {
    
    FILLiquidInterface public _filliquid;

    struct TVLData {
        uint minerNum;
        uint activeMinerNum;
        uint minerBalance;
        uint totalTVL;
        uint availableTVL;
    }

    constructor(address filliquid) {
        _filliquid = FILLiquidInterface(filliquid);
    }

    function getTVL() external view returns (TVLData memory data) {
        uint start = 0;
        uint end = _filliquid.allMinersCount();

        FILLiquid.BindStatusInfo[] memory allMiners = _filliquid.allMinersSubset(start, end);
        for (uint j = 0; j < allMiners.length; j++) {
            FILLiquid.BindStatusInfo memory info = allMiners[j];
            if (!info.status.stillBound) continue;
            data.activeMinerNum++;
            data.minerBalance += minerBalance(info.minerId);
        }

        FILLiquid.FILLiquidInfo memory filLiquidInfo = _filliquid.getStatus();
        data.minerNum = end;
        data.totalTVL = filLiquidInfo.totalFIL;
        data.availableTVL = filLiquidInfo.availableFIL;
    }

    function minerBalance(uint64 minerId) internal view returns (uint) {
        return toAddress(minerId).balance;
    }
    
    function toAddress(uint64 actorId) internal view returns (address) {
        return FilAddressIdConverter.toAddress(actorId);
    }
}