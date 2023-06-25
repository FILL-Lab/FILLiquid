// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/types/MinerTypes.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";

import "./Utils/Validation.sol";
import "./Utils/Convertion.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilAddress.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";

interface FILLiquidInterface {
    struct BorrowInfo {
        bool beingLiquidated; //whether there is existing liquidate in this borrow
        uint id; //borrow id
        uint borrowAmount; //borrow amount
        uint liquidatedAmount; //liquidated amount
        uint remainingOriginalAmount; //remaining original amount
        uint interestRate; //interest rate
        uint datedDate; //borrow start time
    }
    struct BorrowInterestInfo {
        BorrowInfo borrow;
        uint interest;
    }
    struct MinerBorrowInfo {
        uint64 minerId;
        bool alertable;
        bool liquidatable;
        bool haveCollateralizing;
        BorrowInterestInfo[] borrows;
    }
    struct MinerCollateralizingInfo {
        bool liquidateExists;
        uint64 minerId;
        uint64 expiration;
        uint quota;
        uint borrowAmount;
        uint liquidatedAmount;
    }
    struct FILLiquidInfo {
        uint totalFIL;                      // a.   Total FIL Liquidity a=b+c=d+j-e-k
        uint availableFIL;                  // b.	Available FIL Liquidity b=d+i+j-e-h-k-l
        uint utilizedLiquidity;             // c.	Current Utilized Liquidity c=h-i+l
        uint accumulatedDeposit;            // d.	Accumulated Deposited Liquidity
        uint accumulatedRedeem;             // e.	Accumulated FIL Redemptions
        uint accumulatedBurntFILTrust;      // f.	Accumulated FILTrust Burnt
        uint accumulatedMintFILTrust;       // g.	Accumulated FILTrust Mint
        uint accumulatedBorrow;             // h.	Accumulated Borrowed Liquidity
        uint accumulatedPayback;            // i.	Accumulated Repayments
        uint accumulatedInterest;           // j.	Accumulated Interest Payment Received
        uint accumulatedRedeemFee;          // k.	Total Redeem Fee Received
        uint accumulatedBorrowFee;          // l.	Total Borrow Fee Received
        uint accumulatedLiquidateReward;    // m.   Total liquidate reward
        uint accumulatedLiquidateFee;       // n.   Total liquidate fee
        uint utilizationRate;               // o.	Current Utilization Rate n=c/a=(h-i+l)/(d+j-e-k)
        uint exchangeRate;                  // p.	Current FILTrust/FIL Exchange Rate
        uint interestRate;                  // q.	Current Interest Rate
        uint collateralRate;                // r.   Current Collateral Rate
        uint rateBase;                      // s.   Rate base
    }
    struct PaybackResult{
        uint paybackPrincipal;
        uint payBackInterest;
        uint liquidateReward;
        uint liquidateFee;
        uint overpaid;
        uint withdrawn;
    }

    /// @dev deposit FIL to the contract, mint FILTrust
    /// @param amountFIL  the amount of FIL user would like to deposit
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @return amount actual FILTrust minted
    function deposit(uint amountFIL, uint exchangeRate) external payable returns (uint amount);

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

    /// @dev payback principal and interest
    /// @param minerId miner id
    /// @param paybackAmount payback amount
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    function payback(uint64 minerId, uint paybackAmount) external payable returns (uint principal, uint interest);

    /// @dev liquidate process
    /// @param minerId miner id
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    /// @return reward liquidating reward
    /// @return fee liquidating fee
    function liquidate(uint64 minerId) external returns (uint principal, uint interest, uint reward, uint fee);

    /// @dev bind miner with sender address
    /// @param minerId miner id
    /// @param signature miner signature
    function bindMiner(uint64 minerId, bytes memory signature) external;

    /// @dev unbind miner with bound address
    /// @param minerId miner id
    function unbindMiner(uint64 minerId) external;

    /// @dev collateralizing miner : change beneficiary to contract , need owner for miner propose change beneficiary first
    /// @param minerId miner id
    function collateralizingMiner(uint64 minerId) external;

    /// @dev uncollateralizing miner : change beneficiary back to miner owner, need payback all first
    /// @param minerId miner id
    function uncollateralizingMiner(uint64 minerId) external;

    /// @dev FILTrust balance of a user
    /// @param account user account
    /// @return balance user’s FILTrust account balance
    function filTrustBalanceOf(address account) external view returns (uint balance);

    /// @dev user’s borrowing information
    /// @param account user’s account address
    /// @return infos user’s borrowing informations
    function userBorrows(address account) external view returns (MinerBorrowInfo[] memory infos);

    /// @dev get collateralizing miner info : minerId,quota,borrowCount,paybackCount,expiration
    /// @param minerId miner id
    /// @return info return collateralizing miner info
    function getCollateralizingMinerInfo(uint64 minerId) external view returns (MinerCollateralizingInfo memory);

    /// @dev FILTrust token address
    function filTrustAddress() external view returns (address);

    /// @dev Validation contract address
    function validationAddress() external view returns (address);

    /// @dev return FIL/FILTrust exchange rate: total amount of FIL liquidity divided by total amount of FILTrust outstanding
    function exchangeRate() external view returns (uint);

    /// @dev return transaction redeem fee rate
    function redeemFeeRate() external view returns (uint);

    /// @dev return transaction borrow fee rate
    function borrowFeeRate() external view returns (uint);

    /// @dev return transaction borrow fee rate
    function collateralRate() external view returns (uint);

    /// @dev return borrowing interest rate: a mathematical function of utilizatonRate
    function interestRate() external view returns (uint);

    /// @dev return liquidity pool utilization: the amount of FIL being utilized divided by the total liquidity provided (the amount of FIL deposited and the interest repaid)
    function utilizationRate() external view returns (uint);

    /// @dev return fill contract infos
    function filliquidInfo() external view returns (FILLiquidInfo memory);

    /// @dev Emitted when `user` binds `minerId`
    event BindMiner(uint64 indexed minerId, address indexed user);

    /// @dev Emitted when `user` unbinds `minerId`
    event UnbindMiner(uint64 indexed minerId, address indexed user);

    /// @dev Emitted when `account` deposits `amountFIL` and mints `amountFILTrust`
    event Deposit(address indexed account, uint amountFIL, uint amountFILTrust);

    /// @dev Emitted when `account` redeems `amountFILTrust` and withdraws `amountFIL`
    event Redeem(address indexed account, uint amountFILTrust, uint amountFIL, uint fee);

    /// @dev Emitted when collateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration`
    event CollateralizingMiner(uint64 minerId, bytes beneficiary, uint quota, uint64 expiration);

    /// @dev Emitted when uncollateralizing `minerId` : change beneficiary to `beneficiary` with info `quota`,`expiration`
    event UncollateralizingMiner(uint64 minerId, bytes beneficiary, uint quota, uint64 expiration);

    /// @dev Emitted when user `account` borrows `amountFIL` with `minerId`
    event Borrow(
        uint indexed borrowId,
        address indexed account,
        uint64 indexed minerId,
        uint amountFIL,
        uint fee
    );
    
    /// @dev Emitted when user `account` repays `principal + interest` FIL for `borrowId` of `minerId`
    event Payback(
        address account,
        uint64 minerId,
        uint principal,
        uint interest
    );

    /// @dev Emitted when user `account` liquidate `principal + interest + reward + fee` FIL for `borrowId` of `minerId`
    event Liquidate(
        address account,
        uint64 minerId,
        uint principal,
        uint interest,
        uint reward,
        uint fee
    );
}

contract FILLiquid is Context, FILLiquidInterface {
    using Convertion for *;

    mapping(uint64 => BorrowInfo[]) private _minerBorrows;
    mapping(address => uint64[]) private _userMinerPairs;
    mapping(uint64 => address) private _minerBindsMap;
    mapping(uint64 => MinerCollateralizingInfo) private _minerCollateralizing;
    mapping(uint64 => uint) private _liquidatedTimes;
    mapping(uint64 => uint) private _lastLiquidate;
    uint64[] private _allMiners;
    uint private _minerNextBorrowID;

    uint private _accumulatedDepositFIL;
    uint private _accumulatedRedeemFIL;
    uint private _accumulatedBurntFILTrust;
    uint private _accumulatedMintFILTrust;
    uint private _accumulatedBorrowFIL;
    uint private _accumulatedPaybackFIL;
    uint private _accumulatedInterestFIL;
    uint private _accumulatedRedeemFee;
    uint private _accumulatedBorrowFee;
    uint private _accumulatedLiquidateReward;
    uint private _accumulatedLiquidateFee;

    //administrative factors
    address private _owner;
    address payable private _foundation;

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

    //Deposit & Redeem factors
    uint private _u_m;
    uint private _j_n;
    
    //todo : add funcs to reset these addresses?
    FILTrust private _tokenFILTrust;
    Validation private _validation;
    Calculation private _calculation;
    FilecoinAPI private _filecoinAPI;

    uint constant DEFAULT_MIN_DEPOSIT = 1 ether;
    uint constant DEFAULT_MIN_BORROW = 10 ether;
    uint constant DEFAULT_MAX_EXISTING_BORROWS = 3;
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
    uint constant DEFAULT_J_N = 2500000;
    uint constant DEFAULT_MAX_LIQUIDATIONS = 10;
    uint constant DEFAULT_MIN_LIQUIDATE_INTERVAL = 12 hours;
    uint constant DEFAULT_ALERT_THRESHOLD = 750000;
    uint constant DEFAULT_LIQUIDATE_THRESHOLD = 850000;
    uint constant DEFAULT_LIQUIDATE_DISCOUNT_RATE = 900000;
    uint constant DEFAULT_LIQUIDATE_FEE_RATE = 70000;
    uint constant DEFAULT_REQUIRED_QUOTA = 10 ** 68 - 10 ** 18;
    int64 constant DEFAULT_REQUIRED_EXPIRATION = type(int64).max;

    constructor(address filTrustAddr, address validationAddr, address calculationAddr, address filecoinAPI, address payable foundationAddr) {
        _tokenFILTrust = FILTrust(filTrustAddr);
        _validation = Validation(validationAddr);
        _calculation = Calculation(calculationAddr);
        _filecoinAPI = FilecoinAPI(filecoinAPI);
        _owner = _msgSender();
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
        _j_n = DEFAULT_J_N;
    }

    function deposit(uint amountFIL, uint exchRate) public payable returns (uint) {
        require(msg.value == amountFIL, "Value mismatch");
        require(msg.value >= _minDepositAmount, "Value too small");
        uint realTimeExchRate = exchangeRateDeposit(amountFIL);
        checkRateLower(exchRate, realTimeExchRate);
        uint amountFILTrust = amountFIL * realTimeExchRate / _rateBase;
        
        _accumulatedDepositFIL += amountFIL;
        _accumulatedMintFILTrust += amountFILTrust;
        address sender = _msgSender();
        _tokenFILTrust.mint(sender, amountFILTrust);
        
        emit Deposit(sender, amountFIL, amountFILTrust);
        return amountFILTrust;
    }

    function redeem(uint amountFILTrust, uint expectExchRate) external returns (uint, uint) {
        uint realTimeExchRate = exchangeRateRedeem(amountFILTrust);
        checkRateUpper(expectExchRate, realTimeExchRate);
        uint amountFIL = (amountFILTrust * _rateBase) / realTimeExchRate;
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

    function borrow(uint64 minerId, uint amount, uint expectInterestRate) external isBindMinerOrOwner(minerId) haveCollateralizing(minerId) returns (uint, uint) {
        require(amount >= _minBorrowAmount, "Amount lower than minimum");
        require(amount < availableFIL(), "Amount exceeds pool size");
        require(utilizationRateBorrow(amount) <= _u_m, "Utilization rate afterwards exceeds u_m");
        require(_liquidatedTimes[minerId] < _maxLiquidations, "Exceed max liquidation limit");
        MinerCollateralizingInfo storage collateralizingInfo = _minerCollateralizing[minerId];
        require(!collateralizingInfo.liquidateExists, "Existing liquidations");
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        require(borrows.length < _maxExistingBorrows, "Maximum existing borrows");
        (, bool liquidatable,) = liquidateCondition(minerId);
        require(!liquidatable, "Miner liquidatable");
        uint realInterestRate = interestRateBorrow(amount);
        checkRateUpper(expectInterestRate, realInterestRate);
        require(!_filecoinAPI.getAvailableBalance(minerId).neg, "Available balance is negative");
        require(amount <= maxBorrowAllowed(minerId), "Insufficient collateral");
        //todo: check quota and expiration is big enough
        //MinerTypes.BeneficiaryTerm memory term = _filecoinAPI.getBeneficiary(minerId).active.term;
        //require(collateralNeeded + collateralizingInfo.collateralAmount <= term.quota.bigInt2Uint() - term.used_quota.bigInt2Uint(), "Insufficient quota");
        
        uint borrowId = _minerNextBorrowID;
        borrows.push(
            BorrowInfo({
                beingLiquidated: false,
                id: borrowId,
                borrowAmount: amount,
                liquidatedAmount: 0,
                remainingOriginalAmount: amount,
                interestRate: realInterestRate,
                datedDate: block.timestamp
            })
        );
        sortMinerBorrows(minerId);
        _minerNextBorrowID ++;
        collateralizingInfo.borrowAmount += amount;
        uint[2] memory fees = calculateFee(amount, _borrowFeeRate);
        _accumulatedBorrowFIL += fees[0];
        _accumulatedBorrowFee += fees[1];
        _foundation.transfer(fees[1]);
        send(minerId, fees[0]);

        emit Borrow(borrowId, _msgSender(), minerId, fees[0], fees[1]);
        return (fees[0], fees[1]);
    }

    function payback(uint64 minerId, uint amount) external isBindMinerOrOwner (minerId) payable returns (uint, uint) {
        PaybackResult memory r = paybackProcess(minerId, amount, false, true, 0);
        _accumulatedPaybackFIL += r.paybackPrincipal;
        _accumulatedInterestFIL += r.payBackInterest;
        if (r.withdrawn > 0) withdrawBalance(minerId, r.withdrawn);
        if (r.overpaid > 0) payable(_msgSender()).transfer(r.overpaid);

        emit Payback(_msgSender(), minerId, r.paybackPrincipal, r.payBackInterest);
        return (r.paybackPrincipal, r.payBackInterest);
    }

    function paybackWithoutLimit(uint64 minerId, uint amount) external payable returns (uint, uint) {
        PaybackResult memory r = paybackProcess(minerId, amount, false, false, 0);
        _accumulatedPaybackFIL += r.paybackPrincipal;
        _accumulatedInterestFIL += r.payBackInterest;
        if (r.overpaid > 0) payable(_msgSender()).transfer(r.overpaid);

        emit Payback(_msgSender(), minerId, r.paybackPrincipal, r.payBackInterest);
        return (r.paybackPrincipal, r.payBackInterest);
    }

    function liquidate(uint64 minerId) external returns (uint, uint, uint, uint) {
        require(_lastLiquidate[minerId] == 0 || block.timestamp - _lastLiquidate[minerId] >= _minLiquidateInterval, "Insufficient time since last liquidation");
        (, bool liquidatable, uint totalPrincipalAndInterest) = liquidateCondition(minerId);
        require(liquidatable, "Not liquidatable");
        _lastLiquidate[minerId] = block.timestamp;
        _liquidatedTimes[minerId] += 1;
        PaybackResult memory r = paybackProcess(minerId, type(uint).max, true, true, totalPrincipalAndInterest);
        _accumulatedPaybackFIL += r.paybackPrincipal;
        _accumulatedInterestFIL += r.payBackInterest;
        _accumulatedLiquidateReward += r.liquidateReward;
        _accumulatedLiquidateFee += r.liquidateFee;
        if (r.withdrawn > 0) withdrawBalance(minerId, r.withdrawn);
        _foundation.transfer(r.liquidateFee);
        uint bonus = r.overpaid + r.liquidateReward;
        if (bonus > 0) payable(_msgSender()).transfer(bonus);

        emit Liquidate(_msgSender(), minerId, r.paybackPrincipal, r.payBackInterest, r.liquidateReward, r.liquidateFee);
        return (r.paybackPrincipal, r.payBackInterest, r.liquidateReward, r.liquidateFee);
    }

    function bindMiner(uint64 minerId, bytes memory signature) external {
        require(_minerBindsMap[minerId] == address(0), "Unbind first");
        address sender = _msgSender();
        require(_userMinerPairs[sender].length < _maxFamilySize, "Family size too big");
        if (sender != FilAddress.toAddress(_filecoinAPI.getOwnerActorId(minerId))) {
            _validation.validateOwner(minerId, signature, sender);
        }
        _minerBindsMap[minerId] = sender;
        _userMinerPairs[sender].push(minerId);
        _allMiners.push(minerId);

        emit BindMiner(minerId, sender);
    }

    function unbindMiner(uint64 minerId) external isBindMinerOrOwner(minerId) noCollateralizing(minerId){
        require(_minerBindsMap[minerId] != address(0), "Not bound");
        address sender = _msgSender();
        delete _minerBindsMap[minerId];
        uint64[] storage miners = _userMinerPairs[sender];
        for (uint i = 0; i < miners.length; i++) {
            if (miners[i] == minerId) {
                if (i != miners.length - 1) {
                    miners[i] = miners[miners.length - 1];
                }
                miners.pop();
                break;
            }
        }
        for (uint i = 0; i < _allMiners.length; i++) {
            if (_allMiners[i] == minerId) {
                if (i != _allMiners.length - 1) {
                    _allMiners[i] = _allMiners[_allMiners.length - 1];
                }
                _allMiners.pop();
                break;
            }
        }

        emit UnbindMiner(minerId, sender);
    }

    function collateralizingMiner(uint64 minerId) external isBindMinerOrOwner(minerId) noCollateralizing(minerId){
        MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = _filecoinAPI.getBeneficiary(minerId);
        MinerTypes.PendingBeneficiaryChange memory proposedBeneficiaryRet = beneficiaryRet.proposed;
        require(uint(keccak256(abi.encode(_filecoinAPI.getOwner(minerId).owner.data))) == 
        uint(keccak256(abi.encode(beneficiaryRet.active.beneficiary.data))), "Current beneficiary is not owner");
        
        // new_quota check
        uint quota = proposedBeneficiaryRet.new_quota.bigInt2Uint();
        require(quota == _requiredQuota, "Invalid quota");
        int64 expiration = CommonTypes.ChainEpoch.unwrap(proposedBeneficiaryRet.new_expiration);
        uint64 uExpiration = uint64(expiration);
        require(expiration == _requiredExpiration && uExpiration > block.number, "Invalid expiration");

        // change beneficiary to contract
        changeBeneficiary(minerId, proposedBeneficiaryRet.new_beneficiary, proposedBeneficiaryRet.new_quota, proposedBeneficiaryRet.new_expiration);
        _minerCollateralizing[minerId] = MinerCollateralizingInfo({
            liquidateExists: false,
            minerId: minerId,
            expiration: uExpiration,
            quota: quota,
            borrowAmount: 0,
            liquidatedAmount: 0
        });

        emit CollateralizingMiner(
            minerId,
            proposedBeneficiaryRet.new_beneficiary.data,
            quota,
            uExpiration
        );
    }

    function uncollateralizingMiner(uint64 minerId) external isBindMinerOrOwner(minerId) haveCollateralizing(minerId) {
        require(_minerCollateralizing[minerId].borrowAmount == 0, "Payback first");
        require(canMinerExitFamily(minerId), "Cannot exit family");

        // change Beneficiary to owner
        CommonTypes.FilAddress memory minerOwner = _filecoinAPI.getOwner(minerId).owner;
        CommonTypes.FilAddress memory beneficiary = _filecoinAPI.getBeneficiary(minerId).active.beneficiary;
        if (uint(keccak256(abi.encode(beneficiary.data))) != uint(keccak256(abi.encode(minerOwner.data)))) {
            changeBeneficiary(minerId, minerOwner, CommonTypes.BigInt(hex"00", false), CommonTypes.ChainEpoch.wrap(0));
        }
        delete _minerCollateralizing[minerId];

        emit UncollateralizingMiner(minerId, minerOwner.data, 0, 0);
    }

    function filliquidInfo() external view returns (FILLiquidInfo memory) {
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
                accumulatedLiquidateReward: _accumulatedLiquidateReward,
                accumulatedLiquidateFee: _accumulatedLiquidateFee,
                utilizationRate: utilizationRate(),
                exchangeRate: exchangeRate(),
                interestRate: interestRate(),
                collateralRate: _collateralRate,
                rateBase: rateBase()
            });
    }

    function totalFILLiquidity() public view returns (uint) {
        return _accumulatedDepositFIL + _accumulatedInterestFIL - _accumulatedRedeemFIL - _accumulatedRedeemFee;
    }

    function availableFIL() public view returns (uint) {
        return _accumulatedDepositFIL + _accumulatedPaybackFIL + _accumulatedInterestFIL -
        (_accumulatedRedeemFIL + _accumulatedRedeemFee + _accumulatedBorrowFIL + _accumulatedBorrowFee);
    }

    function utilizedLiquidity() public view returns (uint) {
        return _accumulatedBorrowFIL + _accumulatedBorrowFee - _accumulatedPaybackFIL;
    }

    function utilizationRate() public view returns (uint) {
        uint utilized = utilizedLiquidity();
        uint total = totalFILLiquidity();
        if (utilized == total) return _rateBase;
        else return utilized * _rateBase / total;
    }

    function utilizationRateBorrow(uint amount) public view returns (uint) {
        uint total = totalFILLiquidity();
        require(total != 0, "Total FIL Liquidity is 0");
        uint utilized = utilizedLiquidity() + amount;
        require(utilized < total, "Utilized liquidity exceeds total");
        return utilized * _rateBase / total;
    }

    function utilizationRateDeposit(uint amount) public view returns (uint) {
        uint utilized = utilizedLiquidity();
        uint total = totalFILLiquidity() + amount;
        require(total != 0, "Total liquidity is 0");
        return utilized * _rateBase / total;
    }

    function utilizationRateRedeem(uint amount) public view returns (uint) {
        uint utilized = utilizedLiquidity();
        uint totalLiquidity = totalFILLiquidity();
        uint approxFIL = 0;
        if (utilized != totalLiquidity) {
            approxFIL = amount * (totalLiquidity - utilized) * _rateBase / (exchangeRate() * totalLiquidity);
        }
        require(totalLiquidity > approxFIL, "Approximate redeem exceeds total liquidity");
        return utilized * _rateBase / (totalLiquidity - approxFIL);
    }

    function exchangeRate() public view returns (uint) {
        return _calculation.getExchangeRate(utilizationRate(), _u_m, _j_n, _rateBase, _tokenFILTrust.totalSupply(), totalFILLiquidity());
    }

    function exchangeRateDeposit(uint amount) public view returns (uint) {
        return _calculation.getExchangeRate(utilizationRateDeposit(amount), _u_m, _j_n, _rateBase, _tokenFILTrust.totalSupply(), totalFILLiquidity());
    }

    function exchangeRateRedeem(uint amount) public view returns (uint) {
        return _calculation.getExchangeRate(utilizationRateRedeem(amount), _u_m, _j_n, _rateBase, _tokenFILTrust.totalSupply(), totalFILLiquidity());
    }

    function interestRate() public view returns (uint) {
        return _calculation.getInterestRate(utilizationRate(), _u_1, _u_m, _r_0, _r_1, _r_m, _rateBase);
    }

    function interestRateBorrow(uint amount) public view returns (uint) {
        return _calculation.getInterestRate(utilizationRateBorrow(amount), _u_1, _u_m, _r_0, _r_1, _r_m, _rateBase);
    }

    function paybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate) public view returns (uint) {
        return _calculation.getPaybackAmount(borrowAmount, borrowPeriod, annualRate, _rateBase);
    }

    function filTrustBalanceOf(address account) external view returns (uint) {
        return _tokenFILTrust.balanceOf(account);
    }

    function allMiners() external view returns (uint64[] memory) {
        return _allMiners;
    }

    function minerBorrows(uint64 minerId) public view returns (BorrowInterestInfo[] memory result) {
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        result = new BorrowInterestInfo[](borrows.length);
        for (uint i = 0; i < result.length; i++) {
            BorrowInfo storage info = borrows[i];
            result[i].borrow = info;
            result[i].interest = paybackAmount(info.borrowAmount, block.timestamp - info.datedDate, info.interestRate) - info.borrowAmount;
        }
    }

    function userBorrows(address account) external view returns (MinerBorrowInfo[] memory result) {
        result = new MinerBorrowInfo[](_userMinerPairs[account].length);
        for (uint i = 0; i < result.length; i++) {
            uint64 minerId = _userMinerPairs[account][i];
            result[i].minerId = minerId;
            result[i].haveCollateralizing = _minerCollateralizing[minerId].quota > 0;
            result[i].borrows = minerBorrows(minerId);
            (result[i].alertable, result[i].liquidatable,) = liquidateCondition(minerId, result[i].borrows);
        }
    }

    function userMiners(address account) external view returns (uint64[] memory) {
        return _userMinerPairs[account];
    }

    function getCollateralizingMinerInfo(uint64 minerId) external view returns (MinerCollateralizingInfo memory) {
        return _minerCollateralizing[minerId];
    }

    function maxBorrowAllowed(uint64 minerId) public view returns (uint256) {
        uint a = 0;
        uint b = 0;
        uint64[] storage miners = _userMinerPairs[_minerBindsMap[minerId]];
        for (uint i = 0; i < miners.length; i++) {
            a += FilAddress.toAddress(miners[i]).balance;
            b += getPrincipalAndInterest(minerBorrows(minerId));
        }
        a *= _collateralRate;
        b *= _rateBase;
        if (a <= b) return 0;
        else return (a - b) / (_rateBase - _collateralRate);
    }

    function lastLiquidate(uint64 minerId) external view returns (uint) {
        return _lastLiquidate[minerId];
    }

    function liquidatedTimes(uint64 minerId) external view returns (uint) {
        return _liquidatedTimes[minerId];
    }

    function filTrustAddress() external view returns (address) {
        return address(_tokenFILTrust);
    }

    function validationAddress() external view returns (address) {
        return address(_validation);
    }

    function calculationAddress() external view returns (address) {
        return address(_calculation);
    }

    function filecoinAPIAddress() external view returns (address) {
        return address(_filecoinAPI);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function foundation() external view returns (address payable) {
        return _foundation;
    }

    function setFoundation(address payable new_foundation) onlyOwner external {
        _foundation = new_foundation;
    }

    function rateBase() public view returns (uint) {
        return _rateBase;
    }

    function setRateBase(uint new_rateBase) external onlyOwner {
        _rateBase = new_rateBase;
    }

    function redeemFeeRate() external view returns (uint) {
        return _redeemFeeRate;
    }

    function setRedeemFeeRate(uint new_redeemFeeRate) external onlyOwner {
        require(new_redeemFeeRate <= _rateBase, "Invalid value");
        _redeemFeeRate = new_redeemFeeRate;
    }

    function borrowFeeRate() external view returns (uint) {
        return _borrowFeeRate;
    }

    function setBorrowFeeRate(uint new_borrowFeeRate) external onlyOwner {
        require(new_borrowFeeRate <= _rateBase, "Invalid value");
        _borrowFeeRate = new_borrowFeeRate;
    }

    function collateralRate() external view returns (uint) {
        return _collateralRate;
    }

    function setCollateralRate(uint new_collateralRate) external onlyOwner {
        require(new_collateralRate < _rateBase, "Invalid value");
        _collateralRate = new_collateralRate;
    }

    function minDepositAmount() external view returns (uint) {
        return _minDepositAmount;
    }

    function setMinDepositAmount(uint new_minDepositAmount) external onlyOwner {
        _minDepositAmount = new_minDepositAmount;
    }

    function minBorrowAmount() external view returns (uint) {
        return _minBorrowAmount;
    }

    function setMinBorrowAmount(uint new_minBorrowAmount) external onlyOwner {
        _minBorrowAmount = new_minBorrowAmount;
    }

    function maxExistingBorrows() external view returns (uint) {
        return _maxExistingBorrows;
    }

    function setMaxExistingBorrows(uint new_maxExistingBorrows) external onlyOwner {
        _maxExistingBorrows = new_maxExistingBorrows;
    }

    function maxFamilySize() external view returns (uint) {
        return _maxFamilySize;
    }

    function setMaxFamilySize(uint new_maxFamilySize) external onlyOwner {
        _maxFamilySize = new_maxFamilySize;
    }

    function requiredQuota() external view returns (uint) {
        return _requiredQuota;
    }

    function setRequiredQuota(uint new_requiredQuota) external onlyOwner {
        _requiredQuota = new_requiredQuota;
    }

    function requiredExpiration() external view returns (int64) {
        return _requiredExpiration;
    }

    function setRequiredExpiration(int64 new_requiredExpiration) external onlyOwner {
        _requiredExpiration = new_requiredExpiration;
    }

    function maxLiquidations() external view returns (uint) {
        return _maxLiquidations;
    }

    function setMaxLiquidations(uint new_maxLiquidations) external onlyOwner {
        _maxLiquidations = new_maxLiquidations;
    }

    function minLiquidateInterval() external view returns (uint) {
        return _minLiquidateInterval;
    }

    function setMinLiquidateInterval(uint new_minLiquidateInterval) external onlyOwner {
        _minLiquidateInterval = new_minLiquidateInterval;
    }

    function alertThreshold() external view returns (uint) {
        return _alertThreshold;
    }

    function setAlertThreshold(uint new_alertThreshold) external onlyOwner {
        require(new_alertThreshold <= _rateBase, "Invalid value");
        _alertThreshold = new_alertThreshold;
    }

    function liquidateThreshold() external view returns (uint) {
        return _liquidateThreshold;
    }

    function setLiquidateThreshold(uint new_liquidateThreshold) external onlyOwner {
        require(new_liquidateThreshold <= _rateBase, "Invalid value");
        _liquidateThreshold = new_liquidateThreshold;
    }

    function liquidateRewardRate() external view returns (uint) {
        return _rateBase - _liquidateDiscountRate - _liquidateFeeRate;
    }

    function liquidateDiscountRate() external view returns (uint) {
        return _liquidateDiscountRate;
    }

    function liquidateFeeRate() external view returns (uint) {
        return _liquidateFeeRate;
    }

    function setLiquidateRates(uint new_liquidateDiscountRate, uint new_liquidateFeeRate) external onlyOwner {
        require(new_liquidateDiscountRate + new_liquidateFeeRate <= _rateBase && new_liquidateDiscountRate != 0, "Invalid value");
        _liquidateDiscountRate = new_liquidateDiscountRate;
        _liquidateFeeRate = new_liquidateFeeRate;
    }

    function u_1() external view returns (uint) {
        return _u_1;
    }

    //Todo: add logic to check n > 1
    function setU_1(uint new_u_1) external onlyOwner {
        require(new_u_1 <= _rateBase && new_u_1 < _u_m, "Invalid value");
        _u_1 = new_u_1;
    }

    function r_0() external view returns (uint) {
        return _r_0;
    }

    //Todo: add logic to check n > 1
    function setR_0(uint new_r_0) external onlyOwner {
        require(new_r_0 <= _rateBase && new_r_0 < _r_1, "Invalid value");
        _r_0 = new_r_0;
    }

    function r_1() external view returns (uint) {
        return _r_1;
    }

    //Todo: add logic to check n > 1
    function setR_1(uint new_r_1) external onlyOwner {
        require(new_r_1 <= _rateBase && new_r_1 > _r_0 && new_r_1 < _r_m, "Invalid value");
        _r_1 = new_r_1;
    }

    function r_m() external view returns (uint) {
        return _r_m;
    }

    //Todo: add logic to check n > 1
    function setR_M(uint new_r_m) external onlyOwner {
        require(new_r_m <= _rateBase && new_r_m > _r_1, "Invalid value");
        _r_m = new_r_m;
    }

    function u_m() external view returns (uint) {
        return _u_m;
    }

    //Todo: add logic to check n > 1
    function setU_m(uint new_u_m) external onlyOwner {
        require(new_u_m <= _rateBase && new_u_m > _u_1, "Invalid value");
        _u_m = new_u_m;
    }

    function j_n() external view returns (uint) {
        return _j_n;
    }

    //Todo: add logic to check n > 1
    function setJ_n(uint new_j_n) external onlyOwner {
        _j_n = new_j_n;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner allowed");
        _;
    }

    modifier isBindMinerOrOwner(uint64 minerId) {
        address sender = _msgSender();
        require(sender != address(0), "Invalid account");
        require(minerId != 0, "Invalid minerId");
        require(sender == _minerBindsMap[minerId] || sender == FilAddress.toAddress(_filecoinAPI.getOwnerActorId(minerId)), "Not bind or owner");
        _;
    }

    modifier isSameFamily(uint64 minerId) {
        address sender = _msgSender();
        require(sender != address(0), "Invalid account");
        require(minerId != 0, "Invalid minerId");
        require(sender == _minerBindsMap[minerId] || sender == FilAddress.toAddress(_filecoinAPI.getOwnerActorId(minerId)) || _minerBindsMap[minerId] == _minerBindsMap[_filecoinAPI.resolveEthAddress(sender)], "Not same family");
        _;
    }

    modifier noCollateralizing(uint64 _id) {
        require(_minerCollateralizing[_id].quota == 0, "Uncollateralize first");
        _;
    }

    modifier haveCollateralizing(uint64 _id) {
        require(_minerCollateralizing[_id].quota > 0, "Collateralize first");
        _;
    }

    function checkRateLower(uint expectRate, uint realTimeRate) private pure {
        require(expectRate <= realTimeRate, "Expected rate too high");
    }

    function checkRateUpper(uint expectRate, uint realTimeRate) private pure {
        require(realTimeRate <= expectRate, "Expected rate too low");
    }

    function calculateFee(uint input, uint rate) private view returns (uint[2] memory fees) {
        fees[1] = input * rate;
        if (fees[1] % _rateBase == 0) fees[1] /= _rateBase;
        else fees[1] = fees[1] / _rateBase + 1;
        require(fees[1] <= input, "Base amount too small");
        fees[0] = input - fees[1];
    }

    function liquidateCondition(uint64 minerId) private view returns (bool alertable, bool liquidatable, uint principalAndInterest) {
        (alertable, liquidatable, principalAndInterest) = liquidateCondition(minerId, minerBorrows(minerId));
        if (_minerCollateralizing[minerId].liquidateExists) {
            alertable = true;
            liquidatable = true;
        }
    }

    function liquidateCondition(uint64 minerId, BorrowInterestInfo[] memory infos) private view returns (bool alertable, bool liquidatable, uint principalAndInterest) {
        principalAndInterest = getPrincipalAndInterest(infos);
        uint rate = principalAndInterest * _rateBase / FilAddress.toAddress(minerId).balance;
        alertable = rate >= _alertThreshold;
        liquidatable = rate >= _liquidateThreshold;
    }

    function getPrincipalAndInterest(BorrowInterestInfo[] memory infos) private pure returns (uint result) {
        for (uint i = 0; i < infos.length; i++) {
            result += infos[i].interest + infos[i].borrow.borrowAmount;
        }
    }

    function paybackProcess(uint64 minerId, uint amount, bool isLiquidation, bool canWithdraw, uint totalPrincipalAndInterest) private returns (PaybackResult memory r) {
        require(minerId != 0, "Invalid miner id");
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        require(borrows.length != 0, "No borrow exists");
        uint available = _filecoinAPI.getAvailableBalance(minerId).bigInt2Uint();
        if (isLiquidation || amount > available) {
            amount = available;
        }
        if (isLiquidation) {
            uint maxPayBack = (totalPrincipalAndInterest - FilAddress.toAddress(minerId).balance * _collateralRate / _rateBase) * _rateBase / _liquidateDiscountRate;
            if (amount > maxPayBack) amount = maxPayBack;
        }
        uint valueLeft = msg.value;
        uint amountLeft = amount;
        if (!canWithdraw) amountLeft = 0;
        for (uint i = borrows.length - 1; i >= 0; i--) {
            BorrowInfo storage info = borrows[i];
            uint principalAndInterest = paybackAmount(info.borrowAmount, block.timestamp - info.datedDate, info.interestRate);
            uint altogether = valueLeft + amountLeft;
            uint payBackTotal = altogether;
            if (isLiquidation) payBackTotal = altogether * _liquidateDiscountRate / _rateBase;
            if (payBackTotal > principalAndInterest) {
                payBackTotal = principalAndInterest;
                if (isLiquidation) {
                    altogether = payBackTotal * _rateBase / _liquidateDiscountRate;
                }
            }
            if (isLiquidation) {
                uint[2] memory fees = calculateFee(altogether, _liquidateFeeRate);
                r.liquidateFee += fees[1];
                r.liquidateReward += fees[0] - payBackTotal;
                info.beingLiquidated = true;
                info.liquidatedAmount += altogether;
            } else {
                info.beingLiquidated = false;
            }
            uint payBackInterest = principalAndInterest - info.remainingOriginalAmount;
            uint paybackPrincipal = info.remainingOriginalAmount;
            if (payBackTotal < payBackInterest) {
                payBackInterest = payBackTotal;
                paybackPrincipal = 0;
            } else {
                paybackPrincipal = payBackTotal - payBackInterest;
            }
            r.payBackInterest += payBackInterest;
            r.paybackPrincipal += paybackPrincipal;
            info.borrowAmount = principalAndInterest - payBackTotal;
            info.datedDate = block.timestamp;
            info.remainingOriginalAmount -= paybackPrincipal;
            if (valueLeft >= altogether) valueLeft -= altogether;
            else {
                amountLeft -= altogether - valueLeft;
                valueLeft = 0;
            }
            if (valueLeft + amountLeft == 0) break;
        }
        r.overpaid = valueLeft;
        r.withdrawn = amount - amountLeft;
        MinerCollateralizingInfo storage collateralizingInfo = _minerCollateralizing[minerId];
        collateralizingInfo.borrowAmount -= r.paybackPrincipal;
        if (isLiquidation) {
            collateralizingInfo.liquidatedAmount += msg.value + amount - valueLeft - amountLeft;
        }
        bool liquidateExists = false;
        for (uint i = borrows.length - 1; i >= 0; i--) {
            if (borrows[i].borrowAmount == 0) {
                borrows.pop();
            } else if (borrows[i].beingLiquidated) {
                liquidateExists = true;
                break;
            }
        }
        collateralizingInfo.liquidateExists = liquidateExists;
    }

    function sortMinerBorrows(uint64 minerId) private{
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        if (borrows.length < 2) return;
        BorrowInfo memory last = borrows[borrows.length - 1];
        uint index = 0;
        for (; index < borrows.length - 1; index++) {
            if (borrows[index].interestRate >= last.interestRate) break;
        }
        if (index == borrows.length - 1) return;
        for (uint i = borrows.length - 1; i > index; i--) {
            borrows[i] = borrows[i - 1];
        }
        borrows[index] = last;
    }

    function canMinerExitFamily(uint64 minerId) private view returns (bool) {
        uint balanceSum = 0;
        uint principalAndInterestSum = 0;
        uint64[] storage miners = _userMinerPairs[_minerBindsMap[minerId]];
        for (uint i = 0; i < miners.length; i++) {
            if (miners[i] == minerId) continue;
            balanceSum += FilAddress.toAddress(miners[i]).balance;
            principalAndInterestSum += getPrincipalAndInterest(minerBorrows(minerId));
        }
        if (_collateralRate * balanceSum < _rateBase * principalAndInterestSum) return false;
        else return true;
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
        assert(success);
    }

    function withdrawBalance(uint64 minerId, uint withdrawnAmount) private{
        if (withdrawnAmount > 0) {
            (bool success, bytes memory data) = address(_filecoinAPI).delegatecall(
                abi.encodeCall(FilecoinAPI.withdrawBalance, (minerId, withdrawnAmount))
            );
            assert(success);
            assert(uint(bytes32(data)) == withdrawnAmount);
        }
    }

    function send(uint64 minerId, uint sentAmount) private{
        if(sentAmount > 0) {
            (bool success, ) = address(_filecoinAPI).delegatecall(
                abi.encodeCall(FilecoinAPI.send, (minerId, sentAmount))
            );
            assert(success);
        }
    }
}
