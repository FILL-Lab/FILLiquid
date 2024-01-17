// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquidData.sol";
import "./FILLiquidLogic_BorrowPayback.sol";
import "./FILLiquidLogic_DepositRedeem.sol";
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

    FILLiquidData private _filliquidData;
    FILTrust private _filTrust;
    FILStake private _filStake;
    FILGovernance private _filGovernance;
    Governance private _governance;
    FilecoinAPI private _filecoinAPI;

    constructor(FILLiquidData filLiquidDataAddr, FILTrust filTrustAddr, FILStake filStakeAddr, FILGovernance filGovernanceAddr, Governance governanceAddr, FilecoinAPI filecoinAPIAddr) {
        _filliquidData = filLiquidDataAddr;
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
        FILLiquidData.FILLiquidInfo memory filLiquidInfo,
        FILStake.FILStakeInfo memory filStakeInfo,
        Governance.GovernanceInfo memory governanceInfo,
        FiLLiquidGovernanceFactors memory fiLLiquidGovernanceFactors,
        FiLStakeGovernanceFactors memory fiLStakeGovernanceFactors
    ) {
        blockHeight = block.number;
        blockTimeStamp = block.timestamp;
        fitTotalSupply = _filTrust.totalSupply();
        figTotalSupply = _filGovernance.totalSupply();
        filLiquidInfo = _filliquidData.getStatus();
        filStakeInfo = _filStake.getStatus();
        governanceInfo = _governance.getStatus();
        (fiLLiquidGovernanceFactors, fiLStakeGovernanceFactors) = fetchGovernanceFactors();
    }

    function fetchPersonalData(address player) external view returns (
        uint filTrustBalance,
        uint filBalance,
        FILLiquidData.UserInfo memory userInfo
    ) {
        filTrustBalance = _filTrust.balanceOf(player);
        filBalance = player.balance;
        userInfo = _filliquidData.userBorrows(player);
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

    function fetchGovernanceFactors() public view returns (
        FiLLiquidGovernanceFactors memory fiLLiquidGovernanceFactors,
        FiLStakeGovernanceFactors memory fiLStakeGovernanceFactors
    ) {
        (
            fiLLiquidGovernanceFactors.u_1,
            fiLLiquidGovernanceFactors.r_0,
            fiLLiquidGovernanceFactors.r_1,
            fiLLiquidGovernanceFactors.r_m,
            fiLLiquidGovernanceFactors.n
        ) = _filliquidData.getBorrowPayBackFactors();
        (
            ,,,
            fiLLiquidGovernanceFactors.collateralRate,
            fiLLiquidGovernanceFactors.minDepositAmount,
            fiLLiquidGovernanceFactors.minBorrowAmount,
            fiLLiquidGovernanceFactors.maxExistingBorrows,
            fiLLiquidGovernanceFactors.maxFamilySize,
            ,
        ) = _filliquidData.getComprehensiveFactors();
        (
            fiLLiquidGovernanceFactors.maxLiquidations,
            fiLLiquidGovernanceFactors.minLiquidateInterval,
            fiLLiquidGovernanceFactors.alertThreshold,
            fiLLiquidGovernanceFactors.liquidateThreshold,
            fiLLiquidGovernanceFactors.liquidateDiscountRate,
            fiLLiquidGovernanceFactors.liquidateFeeRate
        ) = _filliquidData.getLiquidatingFactors();
        (fiLStakeGovernanceFactors.n_interest, fiLStakeGovernanceFactors.n_stake,,,,,,,) = _filStake.getAllFactors();
    }

    function maxBorrowAllowed(uint64 minerId) external view returns (uint amount) {
        (,address logic_borrow_payback,,,,,) = _filliquidData.getAdministrativeFactors();
        (bool borrowable,) = FILLiquidLogicBorrowPayback(payable(logic_borrow_payback)).getBorrowable(minerId);
        if (!borrowable) return 0;
        amount = _filliquidData.maxBorrowAllowedByUtilization();
        uint amountByMinerId = _filliquidData.maxBorrowAllowed(minerId);
        if (amount > amountByMinerId) amount = amountByMinerId;
        (,,,,,uint minBorrowAmount,,,,) = _filliquidData.getComprehensiveFactors();
        if (amount < minBorrowAmount) amount = 0;
    }

    function getBorrowExpecting(uint amount) external view returns (
        uint expectedInterestRate,
        uint sixMonthInterest
    ){
        (,address logic_borrow_payback,,,,,) = _filliquidData.getAdministrativeFactors();
        FILLiquidLogicBorrowPayback logic = FILLiquidLogicBorrowPayback(payable(logic_borrow_payback));
        expectedInterestRate = logic.interestRateBorrow(amount);
        sixMonthInterest = logic.paybackAmount(amount, 15552000, expectedInterestRate) - amount;
    }

    function getDepositExpecting(uint amountFIL) external view returns (uint expectedAmountFILTrust){
        (address logic_deposit_redeem,,,,,,) = _filliquidData.getAdministrativeFactors();
        expectedAmountFILTrust = FILLiquidLogicDepositRedeem(payable(logic_deposit_redeem)).getFitByDeposit(amountFIL);
    }

    function getRedeemExpecting(uint amountFILTrust) external view returns (uint expectedAmountFIL){
        (address logic_deposit_redeem,,,,,,) = _filliquidData.getAdministrativeFactors();
        expectedAmountFIL = FILLiquidLogicDepositRedeem(payable(logic_deposit_redeem)).getFilByRedeem(amountFILTrust);
    }

    function getBatchedUserBorrows(address[] calldata accounts) external view returns (FILLiquidData.UserInfo[] memory infos) {
        infos = new FILLiquidData.UserInfo[](accounts.length);
        for (uint i = 0; i < infos.length; i++) {
            infos[i] = _filliquidData.userBorrows(accounts[i]);
        }
    }

    function getUserBorrowsByMiner(uint64 minerId) external view returns (FILLiquidData.UserInfo memory infos) {
        return _filliquidData.userBorrows(_filliquidData.minerUser(minerId));
    }

    function getUserBorrowsAndBorrowable(address account) external view returns (FILLiquidData.UserInfo memory info, MinerBorrowable[] memory borrowables) {
        info = _filliquidData.userBorrows(account);
        borrowables = getBorrowable(account);
    }

    function getBorrowable(address account) public view returns (MinerBorrowable[] memory result) {
        uint64[] memory miners = _filliquidData.userMiners(account);
        result = new MinerBorrowable[](miners.length);
        (,address logic_borrow_payback,,,,,) = _filliquidData.getAdministrativeFactors();
        FILLiquidLogicBorrowPayback logic = FILLiquidLogicBorrowPayback(payable(logic_borrow_payback));
        for (uint i = 0; i < miners.length; i++) {
            (result[i].borrowable, result[i].reason) = logic.getBorrowable(miners[i]);
        }
    }

    function getTotalPendingInterest() external view returns (
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
        uint end = _filliquidData.allMinersCount();
        FILLiquidData.FILLiquidInfo memory filLiquidInfo = _filliquidData.getStatus();
        if (start != end) {
            (,address logic_borrow_payback,,,,,) = _filliquidData.getAdministrativeFactors();
            FILLiquidLogicBorrowPayback logic = FILLiquidLogicBorrowPayback(payable(logic_borrow_payback));
            FILLiquidData.BindStatusInfo[] memory allMiners = _filliquidData.allMinersSubset(start, end);
            for (uint j = 0; j < allMiners.length; j++) {
                FILLiquidData.BindStatusInfo memory info = allMiners[j];
                if (!info.status.stillBound) continue;
                FILLiquidData.MinerBorrowInfo memory minerBorrowInfo = _filliquidData.minerBorrows(info.minerId);
                totalPendingInterest += minerBorrowInfo.debtOutStanding - minerBorrowInfo.borrowSum;
                for (uint i = 0; i < minerBorrowInfo.borrows.length; i++) {
                    FILLiquidData.BorrowInfo memory borrowInfo = minerBorrowInfo.borrows[i].borrow;
                    borrowingAndPeriod += borrowInfo.remainingOriginalAmount * (block.timestamp - borrowInfo.initialTime);
                    interestExp += logic.paybackAmount(borrowInfo.borrowAmount, 31536000, borrowInfo.interestRate) - borrowInfo.borrowAmount;
                }
            }
        }
        totalFIL = filLiquidInfo.totalFIL;
        borrowing = filLiquidInfo.utilizedLiquidity;
        accumulatedPayback = filLiquidInfo.accumulatedPayback;
    }

    function getPendingBeneficiary(uint64 minerId) external view returns (address, bool) {
        return _filecoinAPI.getPendingBeneficiaryId(minerId);
    }

    function getAddresses() external view returns (address[6] memory) {
        return [address(_filliquidData), address(_filTrust), address(_filStake), address(_filGovernance), address(_governance), address(_filecoinAPI)];
    }
}