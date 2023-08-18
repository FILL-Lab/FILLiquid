// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquid.sol";
import "./FILTrust.sol";
import "./FILStake.sol";
import "./FILGovernance.sol";
import "./Governance.sol";

contract DataFetcher {
    struct FilComprehensiveFactors {
        uint rateBase;
        uint redeemFeeRate;
        uint borrowFeeRate;
        uint collateralRate;
        uint minDepositAmount;
        uint minBorrowAmount;
        uint maxExistingBorrows;
        uint maxFamilySize;
        uint requiredQuota;
        int64 requiredExpiration;
    }

    struct FilLiquidatingFactors {
        uint maxLiquidations;
        uint minLiquidateInterval;
        uint alertThreshold;
        uint liquidateThreshold;
        uint liquidateDiscountRate;
        uint liquidateFeeRate;
    }

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

    function fetchPersonalData(address player) external returns (
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

    function maxBorrowAllowed(uint64 minerId) external returns (uint amount) {
        amount = _filliquid.maxBorrowAllowedByUtilization();
        uint amountByMinerId = _filliquid.maxBorrowAllowed(minerId);
        if (amount > amountByMinerId) amount = amountByMinerId;
    }

    function getBorrowExpecting(uint amount) external view returns (
        uint expectedInterestRate,
        uint sixMonthInterest
    ){
        expectedInterestRate = _filliquid.interestRateBorrow(amount);
        sixMonthInterest = _filliquid.paybackAmount(amount, 518400, expectedInterestRate) - amount;
    }

    function getDepositExpecting(uint amountFIL) external view returns (
        uint expectedExchangeRate,
        uint expectedAmountFILTrust
    ){
        expectedExchangeRate = _filliquid.exchangeRateDeposit(amountFIL);
        expectedAmountFILTrust = amountFIL * expectedExchangeRate / _filliquid.getStatus().rateBase;
    }

    function getRedeemExpecting(uint amountFILTrust) external view returns (
        uint expectedExchangeRate,
        uint expectedAmountFIL
    ){
        expectedExchangeRate = _filliquid.exchangeRateRedeem(amountFILTrust);
        expectedAmountFIL = amountFILTrust * _filliquid.getStatus().rateBase / expectedExchangeRate;
    }

    function getTotalPendingInterest() external returns (
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

    function getMaximumBorrowable(uint64 minerId) external returns (uint result) {
        (bool borrowable,) = _filliquid.getBorrowable(minerId);
        if (!borrowable) return 0;
        result = _filliquid.maxBorrowAllowed(minerId);
        if (result == 0) return 0;
        (uint rateBase,,,,,uint minBorrowAmount,,,,) = _filliquid.getComprehensiveFactors();
        if (result < minBorrowAmount) return 0;
        (uint u_m,) = _filliquid.getDepositRedeemFactors();
        uint a = _filliquid.totalFILLiquidity() * u_m / rateBase;
        if (a <= 1) return 0;
        a--;
        if (result > a) return a;
    }

    function filliquid() external view returns (address) {
        return address(_filliquid);
    }
}