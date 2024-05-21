// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FILLiquid.sol";
import "./FILTrust.sol";
import "./FITStake.sol";
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
    }

    struct FITStakeGovernanceFactors {
        uint n_interest;
        uint n_stake;
    }

    struct VotingResult {
        uint amountTotal;
        uint amountYes;
        uint amountNo;
        uint amountNoWithVeto;
        uint amountAbstain;
        Governance.voteResult result;
    }

    FILLiquid private _filliquid;
    FILTrust private _filTrust;
    FITStake private _fitStake;
    FILGovernance private _filGovernance;
    Governance private _governance;
    FilecoinAPI private _filecoinAPI;

    constructor(FILLiquid filLiquidAddr, FILTrust filTrustAddr, FITStake fitStakeAddr, FILGovernance filGovernanceAddr, Governance governanceAddr, FilecoinAPI filecoinAPIAddr) {
        _filliquid = filLiquidAddr;
        _filTrust = filTrustAddr;
        _fitStake = fitStakeAddr;
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
        FITStake.FITStakeInfo memory fitStakeInfo,
        Governance.GovernanceInfo memory governanceInfo,
        FiLLiquidGovernanceFactors memory fiLLiquidGovernanceFactors,
        FITStakeGovernanceFactors memory fitStakeGovernanceFactors
    ) {
        blockHeight = block.number;
        blockTimeStamp = block.timestamp;
        fitTotalSupply = _filTrust.totalSupply();
        figTotalSupply = _filGovernance.totalSupply();
        filLiquidInfo = _filliquid.getStatus();
        fitStakeInfo = _fitStake.getStatus();
        governanceInfo = _governance.getStatus();
        (fiLLiquidGovernanceFactors, fitStakeGovernanceFactors) = fetchGovernanceFactors();
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
        uint stakeSum,
        uint totalFIGSum,
        uint releasedFIGSum,
        uint filTrustVariable,
        uint canWithdrawFIGSum,
        uint filTrustLocked,
        uint filGovernanceBalance
    ) {
        filTrustBalance = _filTrust.balanceOf(staker);
        (stakeSum, totalFIGSum, releasedFIGSum, filTrustVariable, canWithdrawFIGSum) = _fitStake.getStakerTerms(staker);
        filTrustLocked = stakeSum - filTrustVariable;
        filGovernanceBalance = _filGovernance.balanceOf(staker);
    }

    function fetchGovernanceFactors() public view returns (
        FiLLiquidGovernanceFactors memory fiLLiquidGovernanceFactors,
        FITStakeGovernanceFactors memory fitStakeGovernanceFactors
    ) {
        (
            fiLLiquidGovernanceFactors.u_1,
            fiLLiquidGovernanceFactors.r_0,
            fiLLiquidGovernanceFactors.r_1,
            fiLLiquidGovernanceFactors.r_m,
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
        uint[9] memory r = _fitStake.getAllFactors();
        fitStakeGovernanceFactors.n_interest = r[0];
        fitStakeGovernanceFactors.n_stake = r[1];
    }

    function maxBorrowAllowed(uint64 minerId) external view returns (uint amount) {
        (bool borrowable,) = _filliquid.getBorrowable(minerId);
        if (!borrowable) return 0;
        amount = _filliquid.maxBorrowAllowedByUtilization();
        uint amountByMinerId = _filliquid.maxBorrowAllowed(minerId);
        if (amount > amountByMinerId) amount = amountByMinerId;
        (,,,,,uint minBorrowAmount,,,,) = _filliquid.getComprehensiveFactors();
        if (amount < minBorrowAmount) amount = 0;
    }

    function maxBorrowAllowedInAdvance(uint64 minerId, uint afterBlocks) external view returns (uint amount) {
        (bool borrowable,) = _filliquid.getBorrowable(minerId);
        if (!borrowable) return 0;
        uint amountAvailable = _filliquid.maxBorrowAllowedByUtilization();
        amount = _maxBorrowAllowedInAdvance(minerId, afterBlocks);
        if (amount > amountAvailable) amount = amountAvailable;
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

    function getBatchedUserBorrows(address[] calldata accounts) external view returns (FILLiquid.UserInfo[] memory infos) {
        infos = new FILLiquid.UserInfo[](accounts.length);
        for (uint i = 0; i < infos.length; i++) {
            infos[i] = _filliquid.userBorrows(accounts[i]);
        }
    }

    function getUserBorrowsByMiner(uint64 minerId) external view returns (FILLiquid.UserInfo memory infos) {
        return _filliquid.userBorrows(_filliquid.minerUser(minerId));
    }

    function getUserBorrowsAndBorrowable(address account) external view returns (FILLiquid.UserInfo memory info, MinerBorrowable[] memory borrowables) {
        info = _filliquid.userBorrows(account);
        borrowables = getBorrowable(account);
    }

    function getBorrowable(address account) public view returns (MinerBorrowable[] memory result) {
        uint64[] memory miners = _filliquid.userMiners(account);
        result = new MinerBorrowable[](miners.length);
        for (uint i = 0; i < miners.length; i++) {
            (result[i].borrowable, result[i].reason) = _filliquid.getBorrowable(miners[i]);
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
                    interestExp += _filliquid.paybackAmount(borrowInfo.borrowAmount, 31536000, borrowInfo.interestRate) - borrowInfo.borrowAmount;
                }
            }
        }
        totalFIL = filLiquidInfo.totalFIL;
        borrowing = filLiquidInfo.utilizedLiquidity;
        accumulatedPayback = filLiquidInfo.accumulatedPayback;
    }

    function getPendingBeneficiary(uint64 minerId) external view returns (FilecoinAPI.Address memory, bool) {
        return _filecoinAPI.getPendingBeneficiaryId(minerId);
    }

    function getProposals(uint[] calldata ids) external view returns(Governance.ProposalInfo[] memory proposals, VotingResult[] memory votings) {
        proposals = new Governance.ProposalInfo[](ids.length);
        votings = new VotingResult[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            uint id = ids[i];
            proposals[i] = _governance.getProposalInfo(id);
            Governance.VotingStatusInfo memory info = _governance.getVoteStatus(id);
            votings[i] = VotingResult(info.amountTotal, info.amounts[0], info.amounts[1], info.amounts[2], info.amounts[3], _governance.getVoteResult(id));
        }
    }

    function getBondsOnProposal(uint proposalId, address account) external view returns(uint votedAmount, uint bondedAmount, uint totalBondedAmount) {
        votedAmount = _governance.votedForProposal(account, proposalId).amountTotal;
        bondedAmount = _governance.bondedAmount(account);
        totalBondedAmount = _governance.getStatus().totalBondedAmount;
    }

    function getFigAmounts(address account) external returns(uint figBalance, uint bondedAmount, uint unbondableAmount) {
        figBalance = _filGovernance.balanceOf(account);
        bondedAmount = _governance.bondedAmount(account);
        (unbondableAmount,,) = _governance.canUnbond(account);
    }

    function getAddresses() external view returns (address[6] memory) {
        return [address(_filliquid), address(_filTrust), address(_fitStake), address(_filGovernance), address(_governance), address(_filecoinAPI)];
    }

    function _toAddress(uint64 minerId) private view returns (FilecoinAPI.Address memory) {
        return _filecoinAPI.toAddress(minerId);
    }

    function _maxBorrowAllowedInAdvance(uint64 minerId, uint afterBlocks) private view returns (uint) {
        uint64[] memory miners = _filliquid.userMiners(_filliquid.minerUser(minerId));
        (uint balanceSum, uint principalAndInterestSum) = (0, 0);
        for (uint j = 0; j < miners.length; j++) {
            FILLiquid.BorrowInterestInfo[] memory borrows = _filliquid.minerBorrows(miners[j]).borrows;
            balanceSum += _toAddress(miners[j]).balance;
            for (uint i = 0; i < borrows.length; i++) {
                FILLiquid.BorrowInfo memory info = borrows[i].borrow;
                principalAndInterestSum += _filliquid.paybackAmount(info.borrowAmount, block.timestamp + 30 * afterBlocks - info.datedTime, info.interestRate);
            }
        }
        return _maxBorrowAllowedByFamilyStatus(balanceSum, principalAndInterestSum);
    }

    function _maxBorrowAllowedByFamilyStatus(uint balanceSum, uint principalAndInterestSum) private view returns (uint) {
        (
            uint rateBase,
            ,,
            uint collateralRate,
            ,,,,,
        ) = _filliquid.getComprehensiveFactors();
        uint a = balanceSum * collateralRate;
        uint b = principalAndInterestSum * rateBase;
        if (a <= b) return 0;
        else return (a - b) / (rateBase - collateralRate);
    }
}