// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Conversion.sol";

interface IFILLiquid {
    struct BorrowInfo {
        uint id; //borrow id
        uint borrowAmount; //borrow amount
        uint remainingOriginalAmount; //remaining original amount
        uint interestRate; //interest rate
        uint datedTime; //borrow start time
        uint initialTime; //borrow initial time
    }
    struct BorrowInterestInfo {
        BorrowInfo borrow;
        uint interest;
    }
    struct LiquidateConditionInfo {
        uint rate;
        bool alertable;
        bool liquidatable;
    }
    struct MinerBorrowInfo {
        uint64 minerId;
        uint debtOutStanding;
        uint balance;
        uint borrowSum;
        Conversion.Integer availableBalance;
        BorrowInterestInfo[] borrows;
    }
    struct UserInfo {
        address user;
        uint debtOutStanding;
        uint availableCredit;
        uint balanceSum;
        uint borrowSum;
        LiquidateConditionInfo liquidateConditionInfo;
        MinerBorrowInfo[] minerBorrowInfo;
    }
    struct MinerCollateralizingInfo {
        uint64 minerId;
        int64 expiration;
        uint quota;
        uint borrowAmount;
        uint liquidatedAmount;
    }
    struct FILLiquidInfo {
        uint totalFIL;                      // a.   Total FIL Liquidity a=b+c=d+j-e-k-m
        uint availableFIL;                  // b.   Available FIL Liquidity b=d+i+j-e-h-k-l
        uint utilizedLiquidity;             // c.   Current Utilized Liquidity c=h-i+l-m
        uint accumulatedDeposit;            // d.   Accumulated Deposited Liquidity
        uint accumulatedRedeem;             // e.   Accumulated FIL Redemptions
        uint accumulatedBurntFILTrust;      // f.   Accumulated FILTrust Burnt
        uint accumulatedMintFILTrust;       // g.   Accumulated FILTrust Mint
        uint accumulatedBorrow;             // h.   Accumulated Borrowed Liquidity
        uint accumulatedPayback;            // i.   Accumulated Repayments
        uint accumulatedInterest;           // j.   Accumulated Interest Payment Received
        uint accumulatedRedeemFee;          // k.   Total Redeem Fee Received
        uint accumulatedBorrowFee;          // l.   Total Borrow Fee Received
        uint accumulatedBadDebt;            // m.   Accumulated Bad Debt
        uint accumulatedLiquidateReward;    // n.   Total liquidate reward
        uint accumulatedLiquidateFee;       // o.   Total liquidate fee
        uint accumulatedDeposits;           // p.   Accumulated Deposites
        uint accumulatedBorrows;            // q.   Accumulated Borrows
        uint utilizationRate;               // r.   Current Utilization Rate s=c/a=(h-i+l-m)/(d+j-e-k-m)
        uint exchangeRate;                  // s.   Current FIL/FILTrust Exchange Rate
        uint interestRate;                  // t.   Current Interest Rate
        uint collateralizedMiner;           // u.   Collateralized miners
        uint minerWithBorrows;              // v.   Miner with Borrows
        uint rateBase;                      // w.   Rate base
    }
    struct FamilyStatus {
        uint balanceSum;
        uint principalAndInterestSum;
        uint principleSum;
    }
    struct BindStatus {
        bool onceBound;
        bool stillBound;
    }
    struct BindStatusInfo {
        uint64 minerId;
        BindStatus status;
    }

    /// @dev deposit FIL to the contract, mint FILTrust
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @return amount actual FILTrust minted
    function deposit(uint exchangeRate) external payable returns (uint amount);

    /// @dev redeem FILTrust to the contract, withdraw FIL
    /// @param amountFILTrust the amount of FILTrust user would like to redeem
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @return amount actual FIL withdrawal
    /// @return fee fee deducted
    function redeem(uint amountFILTrust, uint exchangeRate) external returns (uint amount, uint fee);

    /// @dev borrow FIL from the contract
    /// @param minerId miner id
    /// @param amountFIL the amount of FIL user would like to borrow
    /// @param interestRate approximated interest rate at the point of request
    /// @return amount actual FIL borrowed
    /// @return fee fee deducted
    function borrow(uint64 minerId, uint amountFIL, uint interestRate) external returns (uint amount, uint fee);

    /// @dev payback principal and interest by self
    /// @param minerIdPayee miner id being paid
    /// @param minerIdPayer miner id paying
    /// @param withdrawAmount maximum withdrawal amount
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    /// @return withdrawn withdrawn FIL
    /// @return mintedFIG FIG minted
    function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint withdrawAmount) external payable returns (uint principal, uint interest, uint withdrawn, uint mintedFIG);

    /// @dev payback principal and interest by anyone
    /// @param minerId miner id
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    /// @return mintedFIG FIG minted
    function directPayback(uint64 minerId) external payable returns (uint principal, uint interest, uint mintedFIG);

    /// @dev liquidate process
    /// @param minerIdPayee miner id being paid
    /// @param minerIdPayer miner id paying
    /// @return result liquidating result
    function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) external returns (uint[4] memory result);

    /// @dev collateralizing miner : change beneficiary to contract , need owner for miner propose change beneficiary first
    /// @param minerId miner id
    /// @param signature miner signature
    function collateralizingMiner(uint64 minerId, bytes calldata signature) external;

    /// @dev uncollateralizing miner : change beneficiary back to miner owner, need payback all first
    /// @param minerId miner id
    function uncollateralizingMiner(uint64 minerId) external;

    /// @dev return fill contract infos
    function getStatus() external view returns (FILLiquidInfo memory);

    /// @dev All once bound miners' count
    /// @return count all once bound miners' count
    function allMinersCount() external view returns (uint count);

    /// @dev Once bound miners' subset
    /// @param start start index
    /// @param end end index
    /// @return Once bound miners' subset from `start` to `end` index
    function allMinersSubset(uint start, uint end) external view returns (BindStatusInfo[] memory);

    /// @dev Status of a specified miner
    /// @param minerId miner's actor id
    /// @return Status of a miner with actor id `minerId`
    function minerStatus(uint64 minerId) external view returns (BindStatus memory);

    /// @dev user’s borrowing information
    /// @param account user’s account address
    /// @return infos user’s borrowing informations
    function userBorrows(address account) external view returns (UserInfo memory infos);

    /// @dev user’s bound miners
    /// @param account user’s account address
    /// @return user’s bound miners
    function userMiners(address account) external view returns (uint64[] memory);

    /// @dev get collateralizing miner info: minerId, quota, borrowCount, paybackCount, expiration
    /// @param minerId miner id
    /// @return info return collateralizing miner info
    function getCollateralizingMinerInfo(uint64 minerId) external view returns (MinerCollateralizingInfo memory);

    /// @dev return FIL/FILTrust exchange rate: total amount of FIL liquidity divided by total amount of FILTrust outstanding
    function exchangeRate() external view returns (uint);

    /// @dev return borrowing interest rate: a mathematical function of utilizatonRate
    function interestRate() external view returns (uint);

    /// @dev return liquidity pool utilization: the amount of FIL being utilized divided by the total liquidity provided (the amount of FIL deposited and the interest repaid)
    function utilizationRate() external view returns (uint);

    /// @dev Emitted when `account` deposits `amountFIL` and mints `amountFILTrust`
    event Deposit(address indexed account, uint amountFIL, uint amountFILTrust);

    /// @dev Emitted when `account` redeems `amountFILTrust` and withdraws `amountFIL`
    event Redeem(address indexed account, uint amountFILTrust, uint amountFIL, uint fee);

    /// @dev Emitted when collateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration` by `sender`
    event CollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint quota, int64 expiration);

    /// @dev Emitted when uncollateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration` by `sender`
    event UncollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint quota, int64 expiration);

    /// @dev Emitted when user `account` borrows `amountFIL` with `minerId`
    event Borrow(
        uint indexed borrowId,
        address indexed account,
        uint64 indexed minerId,
        uint amountFIL,
        uint fee,
        uint interestRate,
        uint initialTime
    );
    
    /// @dev Emitted when user `account` repays `principal` + `interest` FIL for `minerIdPayee`,
    /// with `withdrawn` withdrawn from `minerIdPayer` and `principal` + `interest` - `withdrawn` from `account` and `mintedFIG` FIG minted
    event Payback(
        address indexed account,
        uint64 indexed minerIdPayee,
        uint64 indexed minerIdPayer,
        uint principal,
        uint interest,
        uint withdrawn,
        uint mintedFIG
    );

    /// @dev Emitted when user `account` liquidate `principal + interest + reward + fee` FIL for `minerId`
    event Liquidate(
        address indexed account,
        uint64 indexed minerIdPayee,
        uint64 indexed minerIdPayer,
        uint principal,
        uint interest,
        uint reward,
        uint fee
    );

    /// @dev Emitted when Borrow with `id` is updated
    event BorrowUpdated(
        uint indexed borrowId,
        uint borrowAmount,
        uint remainingOriginalAmount,
        uint datedTime
    );

    /// @dev Emitted when Borrow with `id` is droped
    event BorrowDropped(
        uint indexed id
    );

    function setGovernanceFactors(uint[] calldata values) external;
    function checkGovernanceFactors(uint[] calldata values) external view;
    function getBorrowPayBackFactors() external view returns (uint, uint, uint, uint, uint);
    function getComprehensiveFactors() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, int64);
    function getLiquidatingFactors() external view returns (uint, uint, uint, uint, uint, uint);
    function getBorrowable(uint64 minerId) external view returns (bool, string memory);
    function maxBorrowAllowedByUtilization() external view returns (uint);
    function maxBorrowAllowed(uint64 minerId) external view returns (uint);
    function interestRateBorrow(uint amount) external view returns (uint);
    function paybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate) external view returns (uint);
    function getFitByDeposit(uint amountFil) external view returns (uint);
    function getFilByRedeem(uint amountFit) external view returns (uint);
    function minerUser(uint64 minerId) external view returns (address);
    function minerBorrows(uint64 minerId) external view returns (MinerBorrowInfo memory result);
}
