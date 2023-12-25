// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";

import "./Utils/Validation.sol";
import "./Utils/Conversion.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilAddress.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILStake.sol";

interface FILLiquidInterface {
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
        uint64 expiration;
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
    function userBorrows(address account) external returns (UserInfo memory infos);

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
    event CollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint quota, uint64 expiration);

    /// @dev Emitted when uncollateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration` by `sender`
    event UncollateralizingMiner(uint64 indexed minerId, address indexed sender, bytes beneficiary, uint quota, uint64 expiration);

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
}

contract FILLiquid is Context, FILLiquidInterface {
    using Conversion for *;

    mapping(uint64 => BorrowInfo[]) private _minerBorrows;
    mapping(address => uint64[]) private _userMinerPairs;
    mapping(uint64 => address) private _minerBindsMap;
    mapping(uint64 => MinerCollateralizingInfo) private _minerCollateralizing;
    mapping(uint64 => uint) private _liquidatedTimes;
    mapping(uint64 => uint) private _lastLiquidate;
    mapping(uint64 => BindStatus) private _binds;
    mapping(address => uint) private _badDebt;
    uint64[] private _allMiners;
    uint private _collateralizedMiner;
    uint private _minerWithBorrows;

    uint private _accumulatedDepositFIL;
    uint private _accumulatedRedeemFIL;
    uint private _accumulatedBurntFILTrust;
    uint private _accumulatedMintFILTrust;
    uint private _accumulatedBorrowFIL;
    uint private _accumulatedPaybackFIL;
    uint private _accumulatedInterestFIL;
    uint private _accumulatedRedeemFee;
    uint private _accumulatedBorrowFee;
    uint private _accumulatedBadDebt;
    uint private _accumulatedLiquidateReward;
    uint private _accumulatedLiquidateFee;
    uint private _accumulatedDeposits;
    uint private _accumulatedBorrows;

    //administrative factors
    address private _owner;
    address private _governance;
    address payable private _foundation;
    FILTrust private _tokenFILTrust;
    Validation private _validation;
    Calculation private _calculation;
    FilecoinAPI private _filecoinAPI;
    FILStake private _filStake;

    //comprehensive factors
    uint private _rateBase;
    uint private _redeemFeeRate; // redeemFeeRate = _redeemFeeRate / _rateBase
    uint private _borrowFeeRate; // borrowFeeRate = _borrowFeeRate / _rateBase
    uint private _collateralRate; // collateralRate = _collateralRate / _rateBase
    uint private _minDepositAmount; // minimum deposit amount acceptable
    uint private _minBorrowAmount; // minimum borrow amount acceptable
    uint private _maxExistingBorrows; // maximum existing borrows for each miner
    uint private _maxFamilySize; // maximum family size
    uint private _requiredQuota; // require quota upon changing beneficiary
    int64 private _requiredExpiration; // required expiration upon changing beneficiary

    //Liquidating factors
    uint private _maxLiquidations;
    uint private _minLiquidateInterval;
    uint private _alertThreshold;
    uint private _liquidateThreshold;
    uint private _liquidateDiscountRate;
    uint private _liquidateFeeRate;

    //Borrowing & payback interest rate factors
    uint private _u_1;
    uint private _r_0;
    uint private _r_1;
    uint private _r_m;
    uint private _n;

    //Deposit & Redeem factors
    uint private _u_m;

    uint constant DEFAULT_MIN_DEPOSIT = 1 ether;
    uint constant DEFAULT_MIN_BORROW = 10 ether;
    uint constant DEFAULT_MAX_EXISTING_BORROWS = 5;
    uint constant DEFAULT_MAX_FAMILY_SIZE = 5;
    uint constant DEFAULT_RATE_BASE = 1000000;
    uint constant DEFAULT_REDEEM_FEE_RATE = 5000;
    uint constant DEFAULT_BORROW_FEE_RATE = 10000;
    uint constant DEFAULT_COLLATERAL_RATE = 500000;
    uint constant DEFAULT_U_1 = 500000;
    uint constant DEFAULT_R_0 = 10000;
    uint constant DEFAULT_R_1 = 100000;
    uint constant DEFAULT_R_M = 600000;
    uint constant DEFAULT_U_M = 900000;
    uint constant DEFAULT_MAX_LIQUIDATIONS = 10;
    uint constant DEFAULT_MIN_LIQUIDATE_INTERVAL = 12 hours;
    uint constant DEFAULT_ALERT_THRESHOLD = 750000;
    uint constant DEFAULT_LIQUIDATE_THRESHOLD = 850000;
    uint constant DEFAULT_LIQUIDATE_DISCOUNT_RATE = 900000;
    uint constant DEFAULT_LIQUIDATE_FEE_RATE = 70000;
    uint constant DEFAULT_REQUIRED_QUOTA = 1e68 - 1e18;
    int64 constant DEFAULT_REQUIRED_EXPIRATION = type(int64).max;

    constructor(address filTrustAddr, address validationAddr, address calculationAddr, address filecoinAPIAddr, address filStakeAddr, address governanceAddr, address payable foundationAddr) {
        _tokenFILTrust = FILTrust(filTrustAddr);
        _validation = Validation(validationAddr);
        _calculation = Calculation(calculationAddr);
        _filecoinAPI = FilecoinAPI(filecoinAPIAddr);
        _filStake = FILStake(filStakeAddr);
        _owner = _msgSender();
        _governance = governanceAddr;
        _foundation = foundationAddr;
        _rateBase = DEFAULT_RATE_BASE;
        _redeemFeeRate = DEFAULT_REDEEM_FEE_RATE;
        _borrowFeeRate = DEFAULT_BORROW_FEE_RATE;
        _collateralRate = DEFAULT_COLLATERAL_RATE;
        _minDepositAmount = DEFAULT_MIN_DEPOSIT;
        _minBorrowAmount = DEFAULT_MIN_BORROW;
        _maxExistingBorrows = DEFAULT_MAX_EXISTING_BORROWS;
        _maxFamilySize = DEFAULT_MAX_FAMILY_SIZE;
        _requiredQuota = DEFAULT_REQUIRED_QUOTA;
        _requiredExpiration = DEFAULT_REQUIRED_EXPIRATION;
        _maxLiquidations = DEFAULT_MAX_LIQUIDATIONS;
        _minLiquidateInterval = DEFAULT_MIN_LIQUIDATE_INTERVAL;
        _alertThreshold = DEFAULT_ALERT_THRESHOLD;
        _liquidateThreshold = DEFAULT_LIQUIDATE_THRESHOLD;
        _liquidateDiscountRate = DEFAULT_LIQUIDATE_DISCOUNT_RATE;
        _liquidateFeeRate = DEFAULT_LIQUIDATE_FEE_RATE;
        _u_1 = DEFAULT_U_1;
        _r_0 = DEFAULT_R_0;
        _r_1 = DEFAULT_R_1;
        _r_m = DEFAULT_R_M;
        _u_m = DEFAULT_U_M;
        _n = _calculation.getN(_u_1, _u_m, _r_1, _r_m, _rateBase);
    }

    function deposit(uint expectAmountFILTrust) external payable returns (uint) {
        uint amountFIL = msg.value;
        require(amountFIL >= _minDepositAmount, "Value too small");
        uint amountFILTrust = getFitByDeposit(amountFIL);
        isLower(expectAmountFILTrust, amountFILTrust);
        
        _accumulatedDepositFIL += amountFIL;
        _accumulatedMintFILTrust += amountFILTrust;
        _accumulatedDeposits++;
        address sender = _msgSender();
        _tokenFILTrust.mint(sender, amountFILTrust);
        
        emit Deposit(sender, amountFIL, amountFILTrust);
        return amountFILTrust;
    }

    function redeem(uint amountFILTrust, uint expectAmountFIL) external returns (uint, uint) {
        uint amountFIL = getFilByRedeem(amountFILTrust);
        isLower(expectAmountFIL, amountFIL);
        require(amountFIL < availableFIL(), "Insufficient available FIL");

        _accumulatedBurntFILTrust += amountFILTrust;
        uint[2] memory fees = calculateFee(amountFIL, _redeemFeeRate);
        _accumulatedRedeemFIL += fees[0];
        _accumulatedRedeemFee += fees[1];
        address sender = _msgSender();
        _tokenFILTrust.burn(sender, amountFILTrust);
        _foundation.transfer(fees[1]);
        if (fees[0] > 0) payable(sender).transfer(fees[0]);

        emit Redeem(sender, amountFILTrust, fees[0], fees[1]);
        return (fees[0], fees[1]);
    }

    function borrow(uint64 minerId, uint amount, uint expectInterestRate) external isBindMiner(minerId) haveCollateralizing(minerId) returns (uint, uint) {
        (bool borrowable, string memory reason) = getBorrowable(minerId);
        require(borrowable, reason);
        require(amount >= _minBorrowAmount, "Lower than minimum");
        require(amount <= maxBorrowAllowedByUtilization(), "Utilization would exceeds u_m");
        require(amount > 0 && amount <= maxBorrowAllowed(minerId), "Insufficient collateral");
        uint realInterestRate = interestRateBorrow(amount);
        isHigher(expectInterestRate, realInterestRate);

        uint borrowId = _accumulatedBorrows;
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        borrows.push(
            BorrowInfo({
                id: borrowId,
                borrowAmount: amount,
                remainingOriginalAmount: amount,
                interestRate: realInterestRate,
                datedTime: block.timestamp,
                initialTime: block.timestamp
            })
        );

        //sortMinerBorrows
        if (borrows.length >= 2) {
            BorrowInfo memory last = borrows[borrows.length - 1];
            uint index = 0;
            for (; index < borrows.length - 1; index++) {
                if (borrows[index].interestRate > last.interestRate) break;
            }
            for (uint i = borrows.length - 1; i > index; i--) {
                borrows[i] = borrows[i - 1];
            }
            borrows[index] = last;
        }

        _minerCollateralizing[minerId].borrowAmount += amount;
        uint[2] memory fees = calculateFee(amount, _borrowFeeRate);
        _accumulatedBorrowFIL += fees[0];
        _accumulatedBorrowFee += fees[1];
        _accumulatedBorrows++;
        if (borrows.length == 1) _minerWithBorrows++;
        _foundation.transfer(fees[1]);

        if(fees[0] > 0) {
            (bool success, ) = address(_filecoinAPI).delegatecall(
                abi.encodeCall(FilecoinAPI.send, (minerId, fees[0]))
            );
            require(success, "Sending failed");
        }

        emit Borrow(borrowId, _msgSender(), minerId, fees[0], fees[1], realInterestRate, block.timestamp);
        return (fees[0], fees[1]);
    }

    function withdraw4Payback(uint64 minerIdPayee, uint64 minerIdPayer, uint amount) external isBindMiner(minerIdPayee) isSameFamily(minerIdPayee, minerIdPayer) isBorrower(minerIdPayee) payable returns (uint, uint, uint, uint) {
        uint available = _filecoinAPI.getAvailableBalance(minerIdPayer).bigInt2Uint();
        if (amount > available) {
            amount = available;
        }
        
        uint[3] memory r = paybackProcess(minerIdPayee, msg.value + amount);
        uint[2] memory sentBack_withdrawn;
        if (r[0] > amount) {
            sentBack_withdrawn[0] = r[0] - amount;
            payable(_msgSender()).transfer(sentBack_withdrawn[0]);
        } else if (r[0] < amount) {
            sentBack_withdrawn[1] = amount - r[0];
            withdrawBalance(minerIdPayer, sentBack_withdrawn[1]);
        }
        uint mintedFIG = _filStake.handleInterest(_msgSender(), r[1], r[2]);

        emit Payback(_msgSender(), minerIdPayee, minerIdPayer, r[1], r[2], sentBack_withdrawn[1], mintedFIG);
        return (r[1], r[2], sentBack_withdrawn[1], mintedFIG);
    }

    function directPayback(uint64 minerId) external isBorrower(minerId) payable returns (uint, uint, uint) {
        uint[3] memory r = paybackProcess(minerId, msg.value);
        address sender = _msgSender();
        if (r[0] > 0) payable(sender).transfer(r[0]);
        uint mintedFIG = _filStake.handleInterest(_minerBindsMap[minerId], r[1], r[2]);
        emit Payback(sender, minerId, minerId, r[1], r[2], 0, mintedFIG);
        return (r[1], r[2], mintedFIG);
    }

    function liquidate(uint64 minerIdPayee, uint64 minerIdPayer) external isSameFamily(minerIdPayee, minerIdPayer) isBorrower(minerIdPayee) returns (uint[4] memory result) {
        require(_lastLiquidate[minerIdPayee] == 0 || block.timestamp - _lastLiquidate[minerIdPayee] >= _minLiquidateInterval, "Insufficient interval");
        require(liquidateCondition(getFamilyStatus(_minerBindsMap[minerIdPayee])).liquidatable, "Not liquidatable");
        _lastLiquidate[minerIdPayee] = block.timestamp;
        _liquidatedTimes[minerIdPayee] += 1;

        // calculate the maximum amount for pinciple+interest
        uint[3] memory r = paybackProcess(minerIdPayee, _filecoinAPI.getAvailableBalance(minerIdPayer).bigInt2Uint() * _liquidateDiscountRate / _rateBase);
 
        // calculate total withdraw, liquidate fee and reward
        uint totalWithdraw = (r[1] + r[2]) * _rateBase / _liquidateDiscountRate;
        uint[2] memory fees = calculateFee(totalWithdraw, _liquidateFeeRate);
        uint bonus = fees[0] - (r[1] + r[2]);
        _accumulatedLiquidateFee += fees[1];
        _accumulatedLiquidateReward += bonus;
        _minerCollateralizing[minerIdPayee].liquidatedAmount += totalWithdraw;

        if (totalWithdraw > 0) {
            withdrawBalance(minerIdPayer, totalWithdraw);
        }
        _foundation.transfer(fees[1]);
        address sender = _msgSender();
        if (bonus > 0) payable(sender).transfer(bonus);
        result = [r[1], r[2], bonus, fees[1]];

        emit Liquidate(sender, minerIdPayee, minerIdPayer, r[1], r[2], bonus, fees[1]);
    }

    function collateralizingMiner(uint64 minerId, bytes calldata signature) external noCollateralizing(minerId){
        //bindMiner
        require(_minerBindsMap[minerId] == address(0), "Unbind first");
        address sender = _msgSender();
        require(_userMinerPairs[sender].length < _maxFamilySize, "Family size too big");
        if (sender != FilAddress.toAddress(_filecoinAPI.getOwnerActorId(minerId))) {
            _validation.validateOwner(minerId, signature, sender);
        }
        _minerBindsMap[minerId] = sender;
        _userMinerPairs[sender].push(minerId);
        if (!_binds[minerId].onceBound) _allMiners.push(minerId);
        _binds[minerId] = BindStatus(true, true);

        MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = _filecoinAPI.getBeneficiary(minerId);
        MinerTypes.PendingBeneficiaryChange memory proposedBeneficiaryRet = beneficiaryRet.proposed;
        require(uint(keccak256(abi.encode(_filecoinAPI.getOwner(minerId).owner.data))) == 
        uint(keccak256(abi.encode(beneficiaryRet.active.beneficiary.data))), "Beneficiary is not owner");
        
        // new_quota check
        uint quota = proposedBeneficiaryRet.new_quota.bigInt2Uint();
        require(quota == _requiredQuota, "Invalid quota");
        int64 expiration = CommonTypes.ChainEpoch.unwrap(proposedBeneficiaryRet.new_expiration);
        uint64 uExpiration = uint64(expiration);
        require(expiration == _requiredExpiration && uExpiration > block.number, "Invalid expiration");

        // change beneficiary to contract
        changeBeneficiary(minerId, proposedBeneficiaryRet.new_beneficiary, proposedBeneficiaryRet.new_quota, proposedBeneficiaryRet.new_expiration);
        _minerCollateralizing[minerId] = MinerCollateralizingInfo({
            minerId: minerId,
            expiration: uExpiration,
            quota: quota,
            borrowAmount: 0,
            liquidatedAmount: 0
        });
        _collateralizedMiner++;

        emit CollateralizingMiner(
            minerId,
            sender,
            proposedBeneficiaryRet.new_beneficiary.data,
            quota,
            uExpiration
        );
    }

    function uncollateralizingMiner(uint64 minerId) external isBindMiner(minerId) haveCollateralizing(minerId) {
        require(_minerCollateralizing[minerId].borrowAmount == 0, "Payback first");
        address sender = _msgSender();
        require(_badDebt[sender] == 0, "Family with bad debt");
        uint balanceSum = 0;
        uint principalAndInterestSum = 0;
        uint64[] storage miners = _userMinerPairs[sender];
        for (uint i = 0; i < miners.length; i++) {
            if (miners[i] == minerId) continue;
            balanceSum += FilAddress.toAddress(miners[i]).balance;
            principalAndInterestSum += minerBorrows(miners[i]).debtOutStanding;
        }
        require(_collateralRate * balanceSum >= _rateBase * principalAndInterestSum, "Cannot exit family");

        // change Beneficiary to owner
        CommonTypes.FilAddress memory minerOwner = _filecoinAPI.getOwner(minerId).owner;
        changeBeneficiary(minerId, minerOwner, CommonTypes.BigInt(hex"00", false), CommonTypes.ChainEpoch.wrap(0));
        delete _minerCollateralizing[minerId];
        _collateralizedMiner--;

        //unbindMiner
        delete _minerBindsMap[minerId];
        for (uint i = 0; i < miners.length; i++) {
            if (miners[i] == minerId) {
                if (i != miners.length - 1) {
                    miners[i] = miners[miners.length - 1];
                }
                miners.pop();
                break;
            }
        }
        _binds[minerId].stillBound = false;

        emit UncollateralizingMiner(minerId, sender, minerOwner.data, 0, 0);
    }

    function getStatus() external view returns (FILLiquidInfo memory) {
        return
            FILLiquidInfo({
                totalFIL: totalFILLiquidity(),
                availableFIL: availableFIL(),
                utilizedLiquidity: utilizedLiquidity(),
                accumulatedDeposit: _accumulatedDepositFIL,
                accumulatedRedeem: _accumulatedRedeemFIL,
                accumulatedBurntFILTrust: _accumulatedBurntFILTrust,
                accumulatedMintFILTrust: _accumulatedMintFILTrust,
                accumulatedBorrow: _accumulatedBorrowFIL,
                accumulatedPayback: _accumulatedPaybackFIL,
                accumulatedInterest: _accumulatedInterestFIL,
                accumulatedRedeemFee: _accumulatedRedeemFee,
                accumulatedBorrowFee: _accumulatedBorrowFee,
                accumulatedBadDebt: _accumulatedBadDebt,
                accumulatedLiquidateReward: _accumulatedLiquidateReward,
                accumulatedLiquidateFee: _accumulatedLiquidateFee,
                accumulatedDeposits: _accumulatedDeposits,
                accumulatedBorrows: _accumulatedBorrows,
                utilizationRate: utilizationRate(),
                exchangeRate: exchangeRate(),
                interestRate: interestRate(),
                collateralizedMiner: _collateralizedMiner,
                minerWithBorrows: _minerWithBorrows,
                rateBase: _rateBase
            });
    }

    function totalFILLiquidity() public view returns (uint) {
        return _accumulatedDepositFIL + _accumulatedInterestFIL - _accumulatedRedeemFIL - _accumulatedRedeemFee - _accumulatedBadDebt;
    }

    function availableFIL() public view returns (uint) {
        return _accumulatedDepositFIL + _accumulatedPaybackFIL + _accumulatedInterestFIL -
        (_accumulatedRedeemFIL + _accumulatedRedeemFee + _accumulatedBorrowFIL + _accumulatedBorrowFee);
    }

    function utilizedLiquidity() public view returns (uint) {
        return _accumulatedBorrowFIL + _accumulatedBorrowFee - (_accumulatedPaybackFIL + _accumulatedBadDebt);
    }

    function utilizationRate() public view returns (uint) {
        uint utilized = utilizedLiquidity();
        uint total = totalFILLiquidity();
        if (utilized == total) return _rateBase;
        else return utilized * _rateBase / total;
    }

    function utilizationRateBorrow(uint amount) public view returns (uint) {
        uint total = totalFILLiquidity();
        require(total != 0, "Total liquidity is 0");
        uint utilized = utilizedLiquidity() + amount;
        require(utilized < total, "Utilized liquidity exceeds total");
        return utilized * _rateBase / total;
    }

    function exchangeRate() public view returns (uint) {
        return _calculation.getExchangeRate(utilizationRate(), _u_m, _rateBase, _tokenFILTrust.totalSupply(), totalFILLiquidity());
    }

    function getFitByDeposit(uint amountFil) public view returns (uint) {
        return _calculation.getFitByDeposit(amountFil, _u_m, _rateBase, _tokenFILTrust.totalSupply(), totalFILLiquidity(), utilizedLiquidity());
    }

    function getFilByRedeem(uint amountFit) public view returns (uint) {
        return _calculation.getFilByRedeem(amountFit, _u_m, _rateBase, _tokenFILTrust.totalSupply(), totalFILLiquidity(), utilizedLiquidity());
    }

    function interestRate() public view returns (uint) {
        return _calculation.getInterestRate(utilizationRate(), _u_1, _r_0, _r_1, _rateBase, _n);
    }

    function interestRateBorrow(uint amount) public view returns (uint) {
        return _calculation.getInterestRate(utilizationRateBorrow(amount), _u_1, _r_0, _r_1, _rateBase, _n);
    }

    function paybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate) public view returns (uint) {
        return _calculation.getPaybackAmount(borrowAmount, borrowPeriod, annualRate, _rateBase);
    }

    function allMinersCount() external view returns (uint) {
        return _allMiners.length;
    }

    function minerStatus(uint64 minerId) external view returns (BindStatus memory) {
        return _binds[minerId];
    }

    function badDebt(address account) external view returns (uint) {
        return _badDebt[account];
    }

    function allMinersSubset(uint start, uint end) external view returns (BindStatusInfo[] memory result) {
        require(start < end && end <= _allMiners.length, "Invalid indexes");
        result = new BindStatusInfo[](end - start);
        for (uint i = 0; i < end - start; i++) {
            uint64 minerId = _allMiners[i + start];
            result[i].minerId = minerId;
            result[i].status = _binds[minerId];
        }
    }

    function minerBorrows(uint64 minerId) public returns (MinerBorrowInfo memory result) {
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        result.minerId = minerId;
        result.balance = FilAddress.toAddress(minerId).balance;
        result.availableBalance = _filecoinAPI.getAvailableBalance(minerId).bigInt2Integer();
        result.borrows = new BorrowInterestInfo[](borrows.length);
        for (uint i = 0; i < result.borrows.length; i++) {
            BorrowInfo storage info = borrows[i];
            result.borrows[i].borrow = info;
            uint debtOutStanding = paybackAmount(info.borrowAmount, block.timestamp - info.datedTime, info.interestRate);
            result.borrows[i].interest = debtOutStanding - info.remainingOriginalAmount;
            result.debtOutStanding += debtOutStanding;
            result.borrowSum += info.remainingOriginalAmount;
        }
    }

    function userBorrows(address account) external returns (UserInfo memory result) {
        result.user = account;
        result.minerBorrowInfo = new MinerBorrowInfo[](_userMinerPairs[account].length);
        bool borrowable = false;
        for (uint i = 0; i < result.minerBorrowInfo.length; i++) {
            uint64 minerId = _userMinerPairs[account][i];
            result.minerBorrowInfo[i] = minerBorrows(minerId);
            result.debtOutStanding += result.minerBorrowInfo[i].debtOutStanding;
            result.balanceSum += result.minerBorrowInfo[i].balance;
            result.borrowSum += result.minerBorrowInfo[i].borrowSum;
            (bool minerBorrowable,) = getBorrowable(minerId);
            if (minerBorrowable) borrowable = true;
        }
        FamilyStatus memory status = FamilyStatus(result.balanceSum, result.debtOutStanding, result.borrowSum);
        result.liquidateConditionInfo = liquidateCondition(status);
        if (borrowable) {
            result.availableCredit = maxBorrowAllowedByFamilyStatus(status);
            uint x = maxBorrowAllowedByUtilization();
            if (result.availableCredit > x) result.availableCredit = x;
            if (result.availableCredit < _minBorrowAmount) {
                result.availableCredit = 0;
            }
        }
    }

    function userMiners(address account) external view returns (uint64[] memory) {
        return _userMinerPairs[account];
    }

    function minerUser(uint64 minerId) external view returns (address) {
        return _minerBindsMap[minerId];
    }

    function getCollateralizingMinerInfo(uint64 minerId) external view returns (MinerCollateralizingInfo memory) {
        return _minerCollateralizing[minerId];
    }

    function maxBorrowAllowed(uint64 minerId) public returns (uint) {
        return maxBorrowAllowedFamily(_minerBindsMap[minerId]);
    }

    function maxBorrowAllowedFamily(address account) public returns (uint) {
        return maxBorrowAllowedByFamilyStatus(getFamilyStatus(account));
    }

    function maxBorrowAllowedByUtilization() public view returns (uint) {
        uint x = totalFILLiquidity() * _u_m / _rateBase;
        uint y = utilizedLiquidity();
        if (x > y) return x - y;
        else return 0;
    }

    function getFamilyStatus(address account) public returns (FamilyStatus memory status) {
        uint64[] storage miners = _userMinerPairs[account];
        for (uint i = 0; i < miners.length; i++) {
            MinerBorrowInfo memory info = minerBorrows(miners[i]);
            status.balanceSum += info.balance;
            status.principalAndInterestSum += info.debtOutStanding;
            status.principleSum += info.borrowSum;
        }
    }

    function getBorrowable(uint64 minerId) public returns (bool, string memory) {
        uint64[] storage miners = _userMinerPairs[_minerBindsMap[minerId]];
        for (uint i = 0; i < miners.length; i++) {
            if (_liquidatedTimes[miners[i]] >= _maxLiquidations) return (false, "Too many liquidations");
        }
        if (_minerBorrows[minerId].length >= _maxExistingBorrows) return (false, "Too many borrows");
        if (_filecoinAPI.getAvailableBalance(minerId).neg) return (false, "Negtive available balance");
        if (_badDebt[_minerBindsMap[minerId]] != 0) return (false, "Family with bad debt");
        return (true, "");
    }

    function lastLiquidate(uint64 minerId) external view returns (uint) {
        return _lastLiquidate[minerId];
    }

    function liquidatedTimes(uint64 minerId) external view returns (uint) {
        return _liquidatedTimes[minerId];
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function getAdministrativeFactors() external view returns (address, address, address, address, address, address, address payable) {
        return (
            address(_tokenFILTrust),
            address(_validation),
            address(_calculation),
            address(_filecoinAPI),
            address(_filStake),
            _governance,
            _foundation)
        ;
    }

    function setAdministrativeFactors(
        address new_tokenFILTrust,
        address new_validation,
        address new_calculation,
        address new_filecoinAPI,
        address new_filStake,
        address new_governance,
        address payable new_foundation
    ) onlyOwner external {
        _tokenFILTrust= FILTrust(new_tokenFILTrust);
        _validation = Validation(new_validation);
        _calculation = Calculation(new_calculation);
        _filecoinAPI = FilecoinAPI(new_filecoinAPI);
        _filStake = FILStake(new_filStake);
        _governance = new_governance;
        _foundation = new_foundation;
    }

    function getComprehensiveFactors() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, int64) {
        return (
            _rateBase,
            _redeemFeeRate,
            _borrowFeeRate,
            _collateralRate,
            _minDepositAmount,
            _minBorrowAmount,
            _maxExistingBorrows,
            _maxFamilySize,
            _requiredQuota,
            _requiredExpiration
        );
    }

    /*function setComprehensiveFactors(
        uint new_rateBase,
        uint new_redeemFeeRate,
        uint new_borrowFeeRate,
        uint new_collateralRate,
        uint new_minDepositAmount,
        uint new_minBorrowAmount,
        uint new_maxExistingBorrows,
        uint new_maxFamilySize,
        uint new_requiredQuota,
        int64 new_requiredExpiration
    ) external onlyOwner {
        require(
            new_rateBase > 0 &&
            new_redeemFeeRate <= new_rateBase &&
            new_borrowFeeRate <= new_rateBase &&
            new_collateralRate <= new_rateBase &&
            _alertThreshold <= new_rateBase &&
            _liquidateThreshold <= new_rateBase &&
            _liquidateDiscountRate + _liquidateFeeRate <= new_rateBase, "Invalid rates");
        _rateBase = new_rateBase;
        _redeemFeeRate = new_redeemFeeRate;
        _borrowFeeRate = new_borrowFeeRate;
        _collateralRate = new_collateralRate;
        _minDepositAmount = new_minDepositAmount;
        _minBorrowAmount = new_minBorrowAmount;
        _maxExistingBorrows = new_maxExistingBorrows;
        _maxFamilySize = new_maxFamilySize;
        _requiredQuota = new_requiredQuota;
        _requiredExpiration = new_requiredExpiration;
        _n = _calculation.getN(_u_1, _u_m, _r_1, _r_m, _rateBase);
    }*/

    function getLiquidatingFactors() external view returns (uint, uint, uint, uint, uint, uint) {
        return (
            _maxLiquidations,
            _minLiquidateInterval,
            _alertThreshold,
            _liquidateThreshold,
            _liquidateDiscountRate,
            _liquidateFeeRate
        );
    }

    /*function setLiquidatingFactors(
        uint new_maxLiquidations,
        uint new_minLiquidateInterval,
        uint new_alertThreshold,
        uint new_liquidateThreshold,
        uint new_liquidateDiscountRate,
        uint new_liquidateFeeRate
    ) external onlyOwner {
        require(
            new_alertThreshold <= _rateBase &&
            new_liquidateThreshold <= _rateBase &&
            new_liquidateDiscountRate + new_liquidateFeeRate <= _rateBase &&
            new_liquidateDiscountRate != 0, "Invalid rates");
        _maxLiquidations = new_maxLiquidations;
        _minLiquidateInterval = new_minLiquidateInterval;
        _alertThreshold = new_alertThreshold;
        _liquidateThreshold = new_liquidateThreshold;
        _liquidateDiscountRate = new_liquidateDiscountRate;
        _liquidateFeeRate = new_liquidateFeeRate;
    }*/

    function getBorrowPayBackFactors() external view returns (uint, uint, uint, uint, uint) {
        return (_u_1, _r_0, _r_1, _r_m, _n);
    }

    function setGovernanceFactors(uint[] calldata values) external onlyGovernance {
        _u_1 = values[0];
        _r_0 = values[1];
        _r_1 = values[2];
        _r_m = values[3];
        _collateralRate = values[4];
        _maxFamilySize = values[5];
        _alertThreshold = values[6];
        _liquidateThreshold = values[7];
        _maxLiquidations = values[8];
        _minLiquidateInterval = values[9];
        _liquidateDiscountRate = values[10];
        _liquidateFeeRate = values[11];
        _maxExistingBorrows = values[12];
        _minBorrowAmount = values[13];
        _minDepositAmount = values[14];
        _n = _calculation.getN(_u_1, _u_m, _r_1, _r_m, _rateBase);
    }

    function checkGovernanceFactors(uint[] calldata values) external view {
        require(values.length == 15, "Invalid input length");
        require(values[0] <= _rateBase && values[0] < _u_m, "Invalid u_1");
        require(values[1] < values[2], "Invalid r_0");
        require(values[2] < values[3], "Invalid r_1");
        require(values[4] < _rateBase, "Invalid _collateralRate");
        require(values[4] < values[6], "Invalid _alertThreshold");
        require(values[6] < values[7], "Invalid _liquidateThreshold");
        require(values[10] + values[11] <= _rateBase, "Invalid _liquidateDiscountRate and _liquidateFeeRate");
        _calculation.getN(values[0], _u_m, values[2], values[3], _rateBase);
    }

    function getDepositRedeemFactors() external view returns (uint) {
        return (_u_m);
    }

    /*function setDepositRedeemFactors(uint new_u_m) external onlyOwner {
        require(_u_1 < new_u_m && new_u_m <= _rateBase, "Invalid u_m");
        _u_m = new_u_m;
        _n = _calculation.getN(_u_1, _u_m, _r_1, _r_m, _rateBase);
    }*/

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }

    modifier onlyGovernance() {
        require(_msgSender() == _governance, "Not governance");
        _;
    }

    modifier isBindMiner(uint64 minerId) {
        require(_msgSender() == _minerBindsMap[minerId], "Not bind");
        _;
    }

    modifier isSameFamily(uint64 minerIdPayee, uint64 minerIdPayer) {
        require(_minerBindsMap[minerIdPayer] != address(0), "Not bind");
        require(_minerBindsMap[minerIdPayer] == _minerBindsMap[minerIdPayee], "Not same family");
        _;
    }

    modifier isBorrower(uint64 minerId) {
        require(_minerBorrows[minerId].length != 0, "No borrow");
        _;
    }

    modifier noCollateralizing(uint64 _id) {
        require(_minerCollateralizing[_id].quota == 0, "Collateralized");
        _;
    }

    modifier haveCollateralizing(uint64 _id) {
        require(_minerCollateralizing[_id].quota > 0, "Uncollateralized");
        _;
    }

    function isLower(uint expect, uint realtime) private pure {
        require(expect <= realtime, "Too high");
    }

    function isHigher(uint expect, uint realtime) private pure {
        require(realtime <= expect, "Too low");
    }

    function calculateFee(uint input, uint rate) private view returns (uint[2] memory fees) {
        fees[1] = input * rate;
        if (fees[1] % _rateBase == 0) fees[1] /= _rateBase;
        else fees[1] = fees[1] / _rateBase + 1;
        require(fees[1] <= input, "Amount too small");
        fees[0] = input - fees[1];
    }

    function liquidateCondition(FamilyStatus memory status) private view returns (LiquidateConditionInfo memory r) {
        if (status.balanceSum != 0) r.rate = status.principalAndInterestSum * _rateBase / status.balanceSum;
        else if (status.principalAndInterestSum > 0) r.rate = _rateBase;
        r.alertable = r.rate >= _alertThreshold;
        r.liquidatable = r.rate >= _liquidateThreshold;
    }

    function paybackProcess(uint64 minerId, uint amount) private returns (uint[3] memory r) {
        r[0] = amount;
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        for (uint i = borrows.length; i > 0; i--) {
            BorrowInfo storage info = borrows[i - 1];
            uint time = block.timestamp - info.datedTime;
            uint principalAndInterest = paybackAmount(info.borrowAmount, time, info.interestRate);
            uint payBackTotal;
            if (r[0] > principalAndInterest) {
                payBackTotal = principalAndInterest;
                r[0] -= principalAndInterest;
            } else {
                payBackTotal = r[0];
                r[0] = 0;
            }

            uint payBackInterest = principalAndInterest - info.remainingOriginalAmount;
            uint paybackPrincipal;
            if (payBackTotal < payBackInterest) {
                payBackInterest = payBackTotal;
                paybackPrincipal = 0;
            } else {
                paybackPrincipal = payBackTotal - payBackInterest;
            }
            r[2] += payBackInterest;
            r[1] += paybackPrincipal;
            if (principalAndInterest > payBackTotal){
                info.borrowAmount = principalAndInterest - payBackTotal;
                info.datedTime = block.timestamp;
                info.remainingOriginalAmount -= paybackPrincipal;
                emit BorrowUpdated(info.id, info.borrowAmount, info.remainingOriginalAmount, info.datedTime);
            } else {
                emit BorrowDropped(info.id);
                borrows.pop();
            }
            if (r[0] == 0) break;
        }

        if (borrows.length == 0) _minerWithBorrows--;
        MinerCollateralizingInfo storage collateralizingInfo = _minerCollateralizing[minerId];
        collateralizingInfo.borrowAmount -= r[1];
        _accumulatedPaybackFIL += r[1];
        _accumulatedInterestFIL += r[2];

        address user = _minerBindsMap[minerId];
        _accumulatedBadDebt -= _badDebt[user];
        uint balanceSum = 0;
        uint principleSum = 0;
        uint64[] storage miners = _userMinerPairs[user];
        for (uint i = 0; i < miners.length; i++) {
            balanceSum += FilAddress.toAddress(miners[i]).balance;
            BorrowInfo[] storage borrowList = _minerBorrows[miners[i]];
            for (uint j = 0; j < borrowList.length; j++) {
                principleSum += borrowList[j].remainingOriginalAmount;
            }
        }
        if (balanceSum == 0 || _badDebt[user] != 0) {
            _badDebt[user] = principleSum;
            _accumulatedBadDebt += principleSum;
        }
    }

    function maxBorrowAllowedByFamilyStatus(FamilyStatus memory status) private view returns (uint) {
        uint a = status.balanceSum * _collateralRate;
        uint b = status.principalAndInterestSum * _rateBase;
        if (a <= b) return 0;
        else return (a - b) / (_rateBase - _collateralRate);
    }

    function changeBeneficiary(
        uint64 minerId,
        CommonTypes.FilAddress memory beneficiary,
        CommonTypes.BigInt memory quota,
        CommonTypes.ChainEpoch expiration
    ) private{
        (bool success, ) = address(_filecoinAPI).delegatecall(
            abi.encodeCall(FilecoinAPI.changeBeneficiary, (minerId, beneficiary, quota, expiration))
        );
        require(success, "ChangeBeneficiary failed");
    }

    function withdrawBalance(uint64 minerId, uint withdrawnAmount) private{
        if (withdrawnAmount > 0) {
            (bool success, bytes memory data) = address(_filecoinAPI).delegatecall(
                abi.encodeCall(FilecoinAPI.withdrawBalance, (minerId, withdrawnAmount))
            );
            require(success, "WithdrawBalance failed");
            require(uint(bytes32(data)) == withdrawnAmount, "Invalid withdrawal");
        }
    }
}
