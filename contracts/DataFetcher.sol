// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquid.sol";

contract DataFetcher {
    FILLiquid private _filliquid;

    constructor(address fillAddr) {
        _filliquid = FILLiquid(fillAddr);
    }

    function fetchData() external view returns (
        uint blockHeight,
        uint blockTimeStamp,
        FILLiquid.FILLiquidInfo memory info) {
        blockHeight = block.number;
        blockTimeStamp = block.timestamp;
        info = _filliquid.filliquidInfo();
    }

    function fetchPersonalData(address player) external view returns (
        uint filTrustBalance,
        uint filBalance,
        FILLiquid.MinerBorrowInfo[] memory infos
    ) {
        filTrustBalance = _filliquid.filTrustBalanceOf(player);
        filBalance = player.balance;
        infos = _filliquid.userBorrows(player);
    }

    function getTotalPendingInterest() external view returns (uint result) {
        FILLiquid.BindStatusInfo[] memory allMiners = _filliquid.allMinersSubset(0, _filliquid.allMinersCount());
        for (uint j = 0; j < allMiners.length; j++) {
            FILLiquid.BindStatusInfo memory info = allMiners[j];
            if (!info.status.stillBound) continue;
            FILLiquid.BorrowInterestInfo[] memory infos = _filliquid.minerBorrows(info.minerId);
            for (uint i = 0; i < infos.length; i++) {
                result += infos[i].interest;
            }
        }
    }

    function filliquid() external view returns (address) {
        return address(_filliquid);
    }
}