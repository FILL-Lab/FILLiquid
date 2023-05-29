// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./FILL.sol";

contract DataFetcher {
    FILL private _fill;

    constructor(address fillAddr) {
        _fill = FILL(fillAddr);
    }

    function fetchData() external view returns (
        uint blockHeight,
        uint blockTimeStamp,
        FILL.FILLInfo memory info) {
        blockHeight = block.number;
        blockTimeStamp = block.timestamp;
        info = _fill.fillInfo();
    }

    function fetchPersonalData(address player) external view returns (
        uint fleBalance,
        uint filBalance,
        FILL.MinerBorrowInfo[] memory infos
    ) {
        fleBalance = _fill.fleBalanceOf(player);
        filBalance = player.balance;
        infos = _fill.userBorrows(player);
    }

    function fill() external view returns (address) {
        return address(_fill);
    }
}