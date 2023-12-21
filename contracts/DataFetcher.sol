// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquid.sol";
import "./FILTrust.sol";
import "./FILStake.sol";
import "./FILGovernance.sol";
import "./Governance.sol";
import "./Utils/FilecoinAPI.sol";

contract DataFetcher {
    struct MinerBorrowable {
        bool borrowable;
        string reason;
    }

    struct FiLLiquidGovernanceFactors {
        uint u_1;
        uint r_0;
        uint r_1;
        uint r_m;
        uint collateralRate;
        uint maxFamilySize;
        uint alertThreshold;
        uint liquidateThreshold;
        uint maxLiquidations;
        uint minLiquidateInterval;
        uint liquidateDiscountRate;
        uint liquidateFeeRate;
        uint maxExistingBorrows;
        uint minBorrowAmount;
        uint minDepositAmount;
        uint n;
    }

    struct FiLStakeGovernanceFactors {
        uint n_interest;
        uint n_stake;
    }

    FILLiquid private _filliquid;
    FILTrust private _filTrust;
    FILStake private _filStake;
    FILGovernance private _filGovernance;
    Governance private _governance;
    FilecoinAPI private _filecoinAPI;

    constructor(FILLiquid filLiquidAddr, FILTrust filTrustAddr, FILStake filStakeAddr, FILGovernance filGovernanceAddr, Governance governanceAddr, FilecoinAPI filecoinAPIAddr) {
        _filliquid = filLiquidAddr;
        _filTrust = filTrustAddr;
        _filStake = filStakeAddr;
        _filGovernance = filGovernanceAddr;
        _governance = governanceAddr;
        _filecoinAPI = filecoinAPIAddr;
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

    function fetchGovernanceFactors() external view returns (
        FiLLiquidGovernanceFactors memory fiLLiquidGovernanceFactors,
        FiLStakeGovernanceFactors memory fiLStakeGovernanceFactors
    ) {
        (
            fiLLiquidGovernanceFactors.u_1,
            fiLLiquidGovernanceFactors.r_0,
            fiLLiquidGovernanceFactors.r_1,
            fiLLiquidGovernanceFactors.r_m,
            fiLLiquidGovernanceFactors.n
        ) = _filliquid.getBorrowPayBackFactors();
        (
            ,,,
            fiLLiquidGovernanceFactors.collateralRate,
            fiLLiquidGovernanceFactors.minDepositAmount,
            fiLLiquidGovernanceFactors.minBorrowAmount,
            fiLLiquidGovernanceFactors.maxExistingBorrows,
            fiLLiquidGovernanceFactors.maxFamilySize,
            ,
        ) = _filliquid.getComprehensiveFactors();
        (
            fiLLiquidGovernanceFactors.maxLiquidations,
            fiLLiquidGovernanceFactors.minLiquidateInterval,
            fiLLiquidGovernanceFactors.alertThreshold,
            fiLLiquidGovernanceFactors.liquidateThreshold,
            fiLLiquidGovernanceFactors.liquidateDiscountRate,
            fiLLiquidGovernanceFactors.liquidateFeeRate
        ) = _filliquid.getLiquidatingFactors();
        (fiLStakeGovernanceFactors.n_interest, fiLStakeGovernanceFactors.n_stake,,,,,,,) = _filStake.getAllFactors();
    }

    function maxBorrowAllowed(uint64 minerId) external returns (uint amount) {
        (bool borrowable,) = _filliquid.getBorrowable(minerId);
        if (!borrowable) return 0;
        amount = _filliquid.maxBorrowAllowedByUtilization();
        uint amountByMinerId = _filliquid.maxBorrowAllowed(minerId);
        if (amount > amountByMinerId) amount = amountByMinerId;
        (,,,,,uint minBorrowAmount,,,,) = _filliquid.getComprehensiveFactors();
        if (amount < minBorrowAmount) amount = 0;
    }

    function getBorrowExpecting(uint amount) external view returns (
        uint expectedInterestRate,
        uint sixMonthInterest
    ){
        expectedInterestRate = _filliquid.interestRateBorrow(amount);
        sixMonthInterest = _filliquid.paybackAmount(amount, 15552000, expectedInterestRate) - amount;
    }

    function getDepositExpecting(uint amountFIL) external view returns (uint expectedAmountFILTrust){
        expectedAmountFILTrust = _filliquid.getFitByDeposit(amountFIL);
    }

    function getRedeemExpecting(uint amountFILTrust) external view returns (uint expectedAmountFIL){
        expectedAmountFIL = _filliquid.getFilByRedeem(amountFILTrust);
    }

    function getBatchedUserBorrows(address[] calldata accounts) external returns (FILLiquid.UserInfo[] memory infos) {
        infos = new FILLiquid.UserInfo[](accounts.length);
        for (uint i = 0; i < infos.length; i++) {
            infos[i] = _filliquid.userBorrows(accounts[i]);
        }
    }

    function getUserBorrowsByMiner(uint64 minerId) external returns (FILLiquid.UserInfo memory infos) {
        return _filliquid.userBorrows(_filliquid.minerUser(minerId));
    }

    function getUserBorrowsAndBorrowable(address account) external returns (FILLiquid.UserInfo memory info, MinerBorrowable[] memory borrowables) {
        info = _filliquid.userBorrows(account);
        borrowables = getBorrowable(account);
    }

    function getBorrowable(address account) public returns (MinerBorrowable[] memory result) {
        uint64[] memory miners = _filliquid.userMiners(account);
        result = new MinerBorrowable[](miners.length);
        for (uint i = 0; i < miners.length; i++) {
            (result[i].borrowable, result[i].reason) = _filliquid.getBorrowable(miners[i]);
        }
    }

    function getTotalPendingInterest() external returns (
        uint blockHeight,
        uint blockTimeStamp,
        uint totalPendingInterest,
        uint totalFIL,
        uint borrowing,
        uint borrowingAndPeriod,
        uint accumulatedPayback,
        uint interestExp
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
                totalPendingInterest += minerBorrowInfo.debtOutStanding - minerBorrowInfo.borrowSum;
                for (uint i = 0; i < minerBorrowInfo.borrows.length; i++) {
                    FILLiquid.BorrowInfo memory borrowInfo = minerBorrowInfo.borrows[i].borrow;
                    borrowingAndPeriod += borrowInfo.remainingOriginalAmount * (block.timestamp - borrowInfo.initialTime);
                    interestExp += _filliquid.paybackAmount(borrowInfo.borrowAmount, 31536000, borrowInfo.interestRate);
                }
            }
        }
        totalFIL = filLiquidInfo.totalFIL;
        borrowing = filLiquidInfo.utilizedLiquidity;
        accumulatedPayback = filLiquidInfo.accumulatedPayback;
    }

    function getPendingBeneficiary(uint64 minerId) external returns (address, bool) {
        return _filecoinAPI.getPendingBeneficiaryId(minerId);
    }

    function getAddresses() external view returns (address[6] memory) {
        return [address(_filliquid), address(_filTrust), address(_filStake), address(_filGovernance), address(_governance), address(_filecoinAPI)];
    }
}