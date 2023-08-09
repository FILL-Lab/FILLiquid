// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquid.sol";
import "./FILTrust.sol";
import "./FILStake.sol";
import "./FILGovernance.sol";
import "./Governance.sol";

contract DataFetcher {
    FILLiquid private _filliquid;
    FILTrust private _filTrust;
    FILStake private _filStake;
    FILGovernance private _filGovernance;
    Governance private _governance;

    constructor(FILLiquid filLiquidAddr, FILTrust filTrustAddr, FILStake filStakeAddr, FILGovernance filGovernanceAddr, Governance governanceAddr) {
        _filliquid = filLiquidAddr;
        _filTrust = filTrustAddr;
        _filStake = filStakeAddr;
        _filGovernance = filGovernanceAddr;
        _governance = governanceAddr;
    }

    function fetchData() external view returns (
        uint blockHeight,
        uint blockTimeStamp,
        uint fitTotalSupply,
        uint figTotalSupply,
        FILLiquid.FILLiquidInfo memory filLiquidInfo,
        FILStake.FILStakeInfo memory filStakeInfo,
        Governance.GovernanceInfo memory governanceInfo
    ) {
        blockHeight = block.number;
        blockTimeStamp = block.timestamp;
        fitTotalSupply = _filTrust.totalSupply();
        figTotalSupply = _filGovernance.totalSupply();
        filLiquidInfo = _filliquid.getStatus();
        filStakeInfo = _filStake.getStatus();
        governanceInfo = _governance.getStatus();
    }

    function fetchPersonalData(address player) external view returns (
        uint filTrustBalance,
        uint filBalance,
        FILLiquid.UserInfo memory userInfo
    ) {
        filTrustBalance = _filTrust.balanceOf(player);
        filBalance = player.balance;
        userInfo = _filliquid.userBorrows(player);
    }

    function fetchStakerData(address staker) external view returns (
        uint filTrustBalance,
        uint filTrustFixed,
        uint filTrustVariable,
        uint filGovernanceBalance
    ) {
        filTrustBalance = _filTrust.balanceOf(staker);
        (filTrustFixed, filTrustVariable) = _filStake.getStakerTerms(staker);
        filGovernanceBalance = _filGovernance.balanceOf(staker);
    }

    function getTotalPendingInterest() public view returns (
        uint blockHeight,
        uint blockTimeStamp,
        uint totalPendingInterest,
        uint totalFIL,
        uint borrowing,
        uint borrowingAndPeriod,
        uint accumulatedPayback,
        uint accumulatedPaybackFILPeriod
    ) {
        blockHeight = block.number;
        blockTimeStamp = block.timestamp;
        uint start = 0;
        uint end = _filliquid.allMinersCount();
        FILLiquid.FILLiquidInfo memory filLiquidInfo = _filliquid.getStatus();
        if (start != end) {
            FILLiquid.BindStatusInfo[] memory allMiners = _filliquid.allMinersSubset(start, end);
            for (uint j = 0; j < allMiners.length; j++) {
                FILLiquid.BindStatusInfo memory info = allMiners[j];
                if (!info.status.stillBound) continue;
                FILLiquid.MinerBorrowInfo memory minerBorrowInfo = _filliquid.minerBorrows(info.minerId);
                for (uint i = 0; i < minerBorrowInfo.borrows.length; i++) {
                    totalPendingInterest += minerBorrowInfo.borrows[i].interest;
                    borrowingAndPeriod += minerBorrowInfo.borrows[i].borrow.remainingOriginalAmount * (block.number - minerBorrowInfo.borrows[i].borrow.initialTime);
                }
            }
        }
        totalFIL = filLiquidInfo.totalFIL;
        borrowing = filLiquidInfo.utilizedLiquidity;
        accumulatedPayback = filLiquidInfo.accumulatedPayback;
        accumulatedPaybackFILPeriod = filLiquidInfo.accumulatedPaybackFILPeriod;

    }

    function filliquid() external view returns (address) {
        return address(_filliquid);
    }
}