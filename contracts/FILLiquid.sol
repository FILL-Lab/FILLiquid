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
        bool beingSlashed; //whether there is existing slash in this borrow
        uint id; //borrow id
        uint borrowAmount; //borrow amount
        uint slashedAmount; //slashed amount
        uint remainingOriginalAmount; //remaining original amount
        uint interestRate; //interest rate
        uint borrowStartTime; //borrow start time
        uint borrowInitTime; //borrow initializing time
    }
    struct BorrowInterestInfo {
        BorrowInfo borrow;
        uint interest;
    }
    struct MinerBorrowInfo {
        uint64 minerId;
        bool alertable;
        bool slashable;
        bool haveCollateralizing;
        BorrowInterestInfo[] borrows;
    }
    struct MinerCollateralizingInfo {
        bool slashExists;
        uint64 minerId;
        uint64 expiration;
        uint quota;
        uint borrowAmount;
        uint slashedAmount;
    }
    struct FILLiquidInfo {
        uint totalFIL;                  // a.   Total FIL Liquidity a=b+c=d+j-e-k
        uint availableFIL;              // b.	Available FIL Liquidity b=d+i+j-e-h-k-l
        uint utilizedLiquidity;         // c.	Current Utilized Liquidity c=h-i+l
        uint accumulatedDeposit;        // d.	Accumulated Deposited Liquidity
        uint accumulatedRedeem;         // e.	Accumulated FIL Redemptions
        uint accumulatedBurntFILTrust;  // f.	Accumulated FILTrust Burnt
        uint accumulatedMintFILTrust;   // g.	Accumulated FILTrust Mint
        uint accumulatedBorrow;         // h.	Accumulated Borrowed Liquidity
        uint accumulatedPayback;        // i.	Accumulated Repayments
        uint accumulatedInterest;       // j.	Accumulated Interest Payment Received
        uint accumulatedRedeemFee;      // k.	Total Redeem Fee Received
        uint accumulatedBorrowFee;      // l.	Total Borrow Fee Received
        uint accumulatedSlashReward;    // m.   Total slash reward
        uint accumulatedSlashFee;       // n.   Total slash fee
        uint utilizationRate;           // o.	Current Utilization Rate n=c/a=(h-i+l)/(d+j-e-k)
        uint exchangeRate;              // p.	Current FILTrust/FIL Exchange Rate
        uint interestRate;              // q.	Current Interest Rate
        uint collateralRate;            // r.   Current Collateral Rate
        uint rateBase;                  // s.   Rate base
    }
    struct PaybackResult{
        uint paybackPrincipal;
        uint payBackInterest;
        uint slashReward;
        uint slashFee;
        uint overpaid;
        uint withdrawn;
    }

    /// @dev deposit FIL to the contract, mint FILTrust
    /// @param amountFIL  the amount of FIL user would like to deposit
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @param slippageTolr slippage tolerance
    /// @return amount actual FILTrust minted
    function deposit(uint amountFIL, uint exchangeRate, uint slippageTolr) external payable returns (uint amount);

    /// @dev redeem FILTrust to the contract, withdraw FIL
    /// @param amountFILTrust the amount of FILTrust user would like to redeem
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @param slippageTolr slippage tolerance
    /// @return amount actual FIL withdrawal
    /// @return fee fee deducted
    function redeem(uint amountFILTrust, uint exchangeRate, uint slippageTolr) external returns (uint amount, uint fee);

    /// @dev borrow FIL from the contract
    /// @param minerId miner id
    /// @param amountFIL the amount of FIL user would like to borrow
    /// @param interestRate approximated interest rate at the point of request
    /// @param slippageTolr slippage tolerance
    /// @return amount actual FIL borrowed
    /// @return fee fee deducted
    function borrow(uint64 minerId, uint amountFIL, uint interestRate, uint slippageTolr) external returns (uint amount, uint fee);

    /// @dev payback principal and interest
    /// @param minerId miner id
    /// @param borrowId borrow id
    /// @param paybackAmount payback amount
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    function payback(uint64 minerId, uint borrowId, uint paybackAmount) external payable returns (uint principal, uint interest);

    /// @dev slash process
    /// @param minerId miner id
    /// @param borrowId borrow id
    /// @return principal repaid principal FIL
    /// @return interest repaid interest FIL
    /// @return reward slashing reward
    /// @return fee slashing fee
    function slash(uint64 minerId, uint borrowId) external returns (uint principal, uint interest, uint reward, uint fee);

    /// @dev bind miner with sender address
    /// @param minerId miner id
    /// @param signature miner signature
    /// @return success calling result
    function bindMiner(uint64 minerId, bytes memory signature) external returns (bool success);

    /// @dev unbind miner with bound address
    /// @param minerId miner id
    /// @return success calling result
    function unbindMiner(uint64 minerId) external returns (bool success);

    /// @dev collateralizing miner : change beneficiary to contract , need owner for miner propose change beneficiary first
    /// @param minerId miner id
    /// @return flag result flag for change beneficiary
    function collateralizingMiner(uint64 minerId) external returns (bool);

    /// @dev uncollateralizing miner : change beneficiary back to miner owner, need payback all first
    /// @param minerId miner id
    /// @return flag result flag for change beneficiary
    function uncollateralizingMiner(uint64 minerId) external returns (bool);

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
        uint indexed borrowId,
        address indexed account,
        uint64 indexed minerId,
        uint principal,
        uint interest
    );

    /// @dev Emitted when user `account` slash `principal + interest + reward + fee` FIL for `borrowId` of `minerId`
    event Slash(
        uint indexed borrowId,
        address indexed account,
        uint64 indexed minerId,
        uint principal,
        uint interest,
        uint reward,
        uint fee
    );
}

contract FILLiquid is Context, FILLiquidInterface {
    using Convertion for *;

    mapping(uint64 => BorrowInfo[]) private _minerBorrows;
    mapping(address => uint) private _minerNextBorrowID;
    mapping(address => uint64[]) private _userMinerPairs;
    mapping(uint64 => address) private _minerBindsMap;
    mapping(uint64 => MinerCollateralizingInfo) private _minerCollateralizing;
    mapping(uint64 => uint) private _slashedTimes;
    mapping(uint64 => uint) private _lastSlash;
    uint64[] private _allMiners;

    uint private _accumulatedDepositFIL;
    uint private _accumulatedRedeemFIL;
    uint private _accumulatedBurntFILTrust;
    uint private _accumulatedMintFILTrust;
    uint private _accumulatedBorrowFIL;
    uint private _accumulatedPaybackFIL;
    uint private _accumulatedInterestFIL;
    uint private _accumulatedRedeemFee;
    uint private _accumulatedBorrowFee;
    uint private _accumulatedSlashReward;
    uint private _accumulatedSlashFee;

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
    uint private _minBorrowPeriod; // minimum borrow period acceptable
    uint private _maxExistingBorrows; // maximum existing borrows for each miner
    uint private _requiredQuota; // require quota upon changing beneficiary
    int64 private _requiredExpiration; // required expiration upon changing beneficiary

    //Slashing factors
    uint private _maxSlashes;
    uint private _minSlashInterval;
    uint private _alertThreshold;
    uint private _slashThreshold;
    uint private _slashDiscountRate;
    uint private _slashFeeRate;

    //Collateralization rate factors
    uint private _c_m; // collateralizationRate = c_m() * collateralizationGrossRate / (_rateBase * _rateBase)
    uint private _u_d; // Ud = _ud / _rateBase
    uint private _i_n; // i_n = _i_n / _rateBase

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
    uint constant DEFAULT_MIN_BORROW_PERIOD = 2628000; // 1 month
    uint constant DEFAULT_MAX_EXISTING_BORROWS = 3;
    uint constant DEFAULT_RATE_BASE = 1000000;
    uint constant DEFAULT_REDEEM_FEE_RATE = 5000;
    uint constant DEFAULT_BORROW_FEE_RATE = 10000;
    uint constant DEFAULT_COLLATERAL_FEE_RATE = 500000;
    uint constant DEFAULT_C_M = 1500000;
    uint constant DEFAULT_U_D = 800000;
    uint constant DEFAULT_I_N = 10000000;
    uint constant DEFAULT_U_1 = 500000;
    uint constant DEFAULT_R_0 = 10000;
    uint constant DEFAULT_R_1 = 100000;
    uint constant DEFAULT_R_M = 600000;
    uint constant DEFAULT_U_M = 900000;
    uint constant DEFAULT_J_N = 2500000;
    uint constant DEFAULT_MAX_SLASHES = 10;
    uint constant DEFAULT_MIN_SLASH_INTERVAL = 12 hours;
    uint constant DEFAULT_ALERT_THRESHOLD = 800000;
    uint constant DEFAULT_SLASH_THRESHOLD = 850000;
    uint constant DEFAULT_SLASH_DISCOUNT_RATE = 900000;
    uint constant DEFAULT_SLASH_FEE_RATE = 70000;
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
        _collateralRate = DEFAULT_COLLATERAL_FEE_RATE;
        _minDepositAmount = DEFAULT_MIN_DEPOSIT;
        _minBorrowAmount = DEFAULT_MIN_BORROW;
        _minBorrowPeriod = DEFAULT_MIN_BORROW_PERIOD;
        _maxExistingBorrows = DEFAULT_MAX_EXISTING_BORROWS;
        _requiredQuota = DEFAULT_REQUIRED_QUOTA;
        _requiredExpiration = DEFAULT_REQUIRED_EXPIRATION;
        _maxSlashes = DEFAULT_MAX_SLASHES;
        _minSlashInterval = DEFAULT_MIN_SLASH_INTERVAL;
        _alertThreshold = DEFAULT_ALERT_THRESHOLD;
        _slashThreshold = DEFAULT_SLASH_THRESHOLD;
        _slashDiscountRate = DEFAULT_SLASH_DISCOUNT_RATE;
        _slashFeeRate = DEFAULT_SLASH_FEE_RATE;
        _c_m = DEFAULT_C_M;
        _u_d = DEFAULT_U_D;
        _i_n = DEFAULT_I_N;
        _u_1 = DEFAULT_U_1;
        _r_0 = DEFAULT_R_0;
        _r_1 = DEFAULT_R_1;
        _r_m = DEFAULT_R_M;
        _u_m = DEFAULT_U_M;
        _j_n = DEFAULT_J_N;
    }

    function deposit(uint amountFIL, uint exchRate, uint slippage) public payable returns (uint) {
        require(msg.value == amountFIL, "Value mismatch.");
        require(msg.value >= _minDepositAmount, "Value too small.");
        uint realTimeExchRate = exchangeRateDeposit(amountFIL);
        checkRateLower(exchRate, realTimeExchRate, slippage);
        uint amountFILTrust = amountFIL * realTimeExchRate / _rateBase;
        
        _accumulatedDepositFIL += amountFIL;
        _accumulatedMintFILTrust += amountFILTrust;
        address sender = _msgSender();
        _tokenFILTrust.mint(sender, amountFILTrust);
        
        emit Deposit(sender, amountFIL, amountFILTrust);
        return amountFILTrust;
    }

    function redeem(uint amountFILTrust, uint expectExchRate, uint slippage) external returns (uint, uint) {
        uint realTimeExchRate = exchangeRateRedeem(amountFILTrust);
        checkRateUpper(expectExchRate, realTimeExchRate, slippage);
        uint amountFIL = (amountFILTrust * _rateBase) / realTimeExchRate;
        require(amountFIL < availableFIL(), "Insufficient available FIL.");

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

    function borrow(uint64 minerId, uint amount, uint expectInterestRate, uint slippage) external isBindMiner(minerId) returns (uint, uint) {
        haveCollateralizing(minerId);
        require(amount >= _minBorrowAmount, "Amount lower than minimum.");
        require(amount < availableFIL(), "Amount exceeds pool size.");
        require(utilizationRateBorrow(amount) <= _u_m, "Utilization rate afterwards exceeds u_m.");
        require(_slashedTimes[minerId] < _maxSlashes, "Miner exceeds max slashed limit.");
        MinerCollateralizingInfo storage collateralizingInfo = _minerCollateralizing[minerId];
        require(!collateralizingInfo.slashExists, "Miner with existing slashes cannot borrow.");
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        require(borrows.length < _maxExistingBorrows, "Have reached maximum existing borrows.");
        (, bool slashable) = slashCondition(minerId);
        require(!slashable, "Miner is slashable.");
        uint realInterestRate = interestRateBorrow(amount);
        checkRateUpper(expectInterestRate, realInterestRate, slippage);
        require(!_filecoinAPI.getAvailableBalance(minerId).neg, "Available balance cannot be negative.");
        require(amount <= maxBorrowAllowed(minerId), "Insufficient collateral to borrow.");
        //todo: check quota and expiration is big enough
        //MinerTypes.BeneficiaryTerm memory term = _filecoinAPI.getBeneficiary(minerId).active.term;
        //require(collateralNeeded + collateralizingInfo.collateralAmount <= term.quota.bigInt2Uint() - term.used_quota.bigInt2Uint(), "Insufficient quota.");
        
        uint borrowId = _minerNextBorrowID[_msgSender()];
        borrows.push(
            BorrowInfo({
                beingSlashed: false,
                id: borrowId,
                borrowAmount: amount,
                slashedAmount: 0,
                remainingOriginalAmount: amount,
                interestRate: realInterestRate,
                borrowStartTime: block.timestamp,
                borrowInitTime: block.timestamp
            })
        );
        _minerNextBorrowID[_msgSender()] ++;
        collateralizingInfo.borrowAmount += amount;
        uint[2] memory fees = calculateFee(amount, _borrowFeeRate);
        _accumulatedBorrowFIL += fees[0];
        _accumulatedBorrowFee += fees[1];
        _foundation.transfer(fees[1]);
        send(minerId, fees[0]);

        emit Borrow(borrowId, _msgSender(), minerId, fees[0], fees[1]);
        return (fees[0], fees[1]);
    }

    function payback(uint64 minerId, uint borrowId, uint amount) external isBindMiner(minerId) payable returns (uint, uint) {
        PaybackResult memory r = paybackProcess(minerId, borrowId, amount, false);
        _accumulatedPaybackFIL += r.paybackPrincipal;
        _accumulatedInterestFIL += r.payBackInterest;
        withdrawBalance(minerId, r.withdrawn);
        if (r.overpaid > 0) payable(_msgSender()).transfer(r.overpaid);

        emit Payback(borrowId, _msgSender(), minerId, r.paybackPrincipal, r.payBackInterest);
        return (r.paybackPrincipal, r.payBackInterest);
    }

    function slash(uint64 minerId, uint borrowId) external returns (uint, uint, uint, uint) {
        require(_lastSlash[minerId] == 0 || block.timestamp - _lastSlash[minerId] >= _minSlashInterval, "Insufficient time past since last slash.");
        (, bool slashable) = slashCondition(minerId);
        require(slashable, "Miner cannot be slashed.");
        _lastSlash[minerId] = block.timestamp;
        _slashedTimes[minerId] += 1;
        PaybackResult memory r = paybackProcess(minerId, borrowId, type(uint).max, true);
        _accumulatedPaybackFIL += r.paybackPrincipal;
        _accumulatedInterestFIL += r.payBackInterest;
        _accumulatedSlashReward += r.slashReward;
        _accumulatedSlashFee += r.slashFee;
        withdrawBalance(minerId, r.withdrawn);
        _foundation.transfer(r.slashFee);
        uint bonus = r.overpaid + r.slashReward;
        if (bonus > 0) payable(_msgSender()).transfer(bonus);

        emit Slash(borrowId, _msgSender(), minerId, r.paybackPrincipal, r.payBackInterest, r.slashReward, r.slashFee);
        return (r.paybackPrincipal, r.payBackInterest, r.slashReward, r.slashFee);
    }

    function bindMiner(uint64 minerId, bytes memory signature) external returns (bool) {
        require(_minerBindsMap[minerId] == address(0), "Unbind first.");
        address sender = _msgSender();
        _validation.validateOwner(minerId, signature, sender);
        _minerBindsMap[minerId] = sender;
        _userMinerPairs[sender].push(minerId);
        _allMiners.push(minerId);

        emit BindMiner(minerId, sender);
        return true;
    }

    function unbindMiner(uint64 minerId) external isBindMiner(minerId) returns (bool) {
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
        return true;
    }

    function collateralizingMiner(uint64 minerId) external isBindMiner(minerId) returns (bool) {
        noCollateralizing(minerId);
        MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = _filecoinAPI.getBeneficiary(minerId);
        MinerTypes.PendingBeneficiaryChange memory proposedBeneficiaryRet = beneficiaryRet.proposed;
        require(uint(keccak256(abi.encode(_filecoinAPI.getOwner(minerId).owner.data))) == 
        uint(keccak256(abi.encode(beneficiaryRet.active.beneficiary.data))), "Current beneficiary is not owner.");
        
        // new_quota check
        uint quota = Convertion.bigInt2Uint(proposedBeneficiaryRet.new_quota);
        require(quota == _requiredQuota, "Invalid quota.");
        int64 expiration = CommonTypes.ChainEpoch.unwrap(proposedBeneficiaryRet.new_expiration);
        require(expiration == _requiredExpiration, "Invalid expiration.");
        uint64 uExpiration = uint64(expiration);
        require(
            uExpiration > block.number,
            "Expiration invalid."
        );

        // change beneficiary to contract
        changeBeneficiary(minerId, proposedBeneficiaryRet.new_beneficiary, proposedBeneficiaryRet.new_quota, proposedBeneficiaryRet.new_expiration);
        _minerCollateralizing[minerId] = MinerCollateralizingInfo({
            slashExists: false,
            minerId: minerId,
            expiration: uExpiration,
            quota: quota,
            borrowAmount: 0,
            slashedAmount: 0
        });

        emit CollateralizingMiner(
            minerId,
            proposedBeneficiaryRet.new_beneficiary.data,
            quota,
            uExpiration
        );
        return true;
    }

    function uncollateralizingMiner(uint64 minerId) external isBindMiner(minerId) returns (bool) {
        haveCollateralizing(minerId);
        require(
            _minerCollateralizing[minerId].borrowAmount == 0,
            "Payback first."
        );

        // change Beneficiary to owner
        CommonTypes.FilAddress memory minerOwner = _filecoinAPI.getOwner(minerId).owner;
        CommonTypes.FilAddress memory beneficiary = _filecoinAPI.getBeneficiary(minerId).active.beneficiary;
        if (uint(keccak256(abi.encode(beneficiary.data))) != uint(keccak256(abi.encode(minerOwner.data)))) {
            changeBeneficiary(minerId, minerOwner, CommonTypes.BigInt(hex"00", false), CommonTypes.ChainEpoch.wrap(0));
        }
        delete _minerCollateralizing[minerId];

        emit UncollateralizingMiner(minerId, minerOwner.data, 0, 0);
        return true;
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
                accumulatedSlashReward: _accumulatedSlashReward,
                accumulatedSlashFee: _accumulatedSlashFee,
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
        require(total != 0, "Total FIL Liquidity is 0.");
        uint utilized = utilizedLiquidity() + amount;
        require(utilized < total, "Utilized liquidity should be smaller than total liquidity.");
        return utilized * _rateBase / total;
    }

    function utilizationRateDeposit(uint amount) public view returns (uint) {
        uint utilized = utilizedLiquidity();
        uint total = totalFILLiquidity() + amount;
        require(total != 0, "Total FIL Liquidity is 0.");
        return utilized * _rateBase / total;
    }

    function utilizationRateRedeem(uint amount) public view returns (uint) {
        uint utilized = utilizedLiquidity();
        uint totalLiquidity = totalFILLiquidity();
        uint approxFIL = 0;
        if (utilized != totalLiquidity) {
            approxFIL = amount * (totalLiquidity - utilized) * _rateBase / (exchangeRate() * totalLiquidity);
        }
        require(totalLiquidity > approxFIL, "Approximate redeem amount must be smaller than total liquidity.");
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

    function collateralizationRate(uint64 minerId) public view returns (uint) {
        return _calculation.getCollateralizationRate(utilizationRate(), c_m(minerId), _u_d, _i_n, _rateBase);
    }

    /*function collateralizationRateBorrow(uint64 minerId, uint amount) public view returns (uint) {
        return _calculation.getCollateralizationRate(utilizationRateBorrow(amount), c_m(minerId), _u_d, _i_n, _rateBase);
    }*/

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
            result[i].interest = paybackAmount(info.borrowAmount, block.timestamp - info.borrowStartTime, info.interestRate) - info.borrowAmount;
        }
    }

    function userBorrows(address account) external view returns (MinerBorrowInfo[] memory result) {
        result = new MinerBorrowInfo[](_userMinerPairs[account].length);
        for (uint i = 0; i < result.length; i++) {
            uint64 minerId = _userMinerPairs[account][i];
            result[i].minerId = minerId;
            result[i].haveCollateralizing = _minerCollateralizing[minerId].quota > 0;
            result[i].borrows = minerBorrows(minerId);
            (result[i].alertable, result[i].slashable) = slashCondition(minerId, result[i].borrows);
        }
    }

    function userMiners(address account) external view returns (uint64[] memory) {
        return _userMinerPairs[account];
    }

    function getCollateralizingMinerInfo(uint64 minerId) external view returns (MinerCollateralizingInfo memory) {
        return _minerCollateralizing[minerId];
    }

    function maxBorrowAllowed(uint64 minerId) public view returns (uint256) {
        uint a = _collateralRate * FilAddress.toAddress(minerId).balance;
        uint b = _rateBase * getPrincipalAndInterest(minerBorrows(minerId));
        if (a <= b) return 0;
        else return (a - b) / (_rateBase - _collateralRate);
    }

    function lastSlash(uint64 minerId) external view returns (uint) {
        return _lastSlash[minerId];
    }

    function slashedTimes(uint64 minerId) external view returns (uint) {
        return _slashedTimes[minerId];
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

    function setOwner(address new_owner) onlyOwner external returns (address) {
        _owner = new_owner;
        return _owner;
    }

    function foundation() external view returns (address payable) {
        return _foundation;
    }

    function setFoundation(address payable new_foundation) onlyOwner external returns (address payable) {
        _foundation = new_foundation;
        return _foundation;
    }

    function rateBase() public view returns (uint) {
        return _rateBase;
    }

    function setRateBase(uint new_rateBase) external onlyOwner returns (uint) {
        _rateBase = new_rateBase;
        return _rateBase;
    }

    function redeemFeeRate() external view returns (uint) {
        return _redeemFeeRate;
    }

    function setRedeemFeeRate(uint new_redeemFeeRate) external onlyOwner returns (uint) {
        require(new_redeemFeeRate <= _rateBase, "Invalid redeem fee rate.");
        _redeemFeeRate = new_redeemFeeRate;
        return _redeemFeeRate;
    }

    function borrowFeeRate() external view returns (uint) {
        return _borrowFeeRate;
    }

    function setBorrowFeeRate(uint new_borrowFeeRate) external onlyOwner returns (uint) {
        require(new_borrowFeeRate <= _rateBase, "Invalid borrow fee rate.");
        _borrowFeeRate = new_borrowFeeRate;
        return _borrowFeeRate;
    }

    function collateralRate() external view returns (uint) {
        return _collateralRate;
    }

    function setCollateralRate(uint new_collateralRate) external onlyOwner returns (uint) {
        require(new_collateralRate < _rateBase, "Invalid collateral fee rate.");
        _collateralRate = new_collateralRate;
        return _collateralRate;
    }

    function minDepositAmount() external view returns (uint) {
        return _minDepositAmount;
    }

    function setMinDepositAmount(uint new_minDepositAmount) external onlyOwner returns (uint) {
        _minDepositAmount = new_minDepositAmount;
        return _minDepositAmount;
    }

    function minBorrowAmount() external view returns (uint) {
        return _minBorrowAmount;
    }

    function setMinBorrowAmount(uint new_minBorrowAmount) external onlyOwner returns (uint) {
        _minBorrowAmount = new_minBorrowAmount;
        return _minBorrowAmount;
    }

    function minBorrowPeriod() external view returns (uint) {
        return _minBorrowPeriod;
    }

    function setMinBorrowPeriod(uint new_minBorrowPeriod) external onlyOwner returns (uint) {
        _minBorrowPeriod = new_minBorrowPeriod;
        return _minBorrowPeriod;
    }

    function maxExistingBorrows() external view returns (uint) {
        return _maxExistingBorrows;
    }

    function setMaxExistingBorrows(uint new_maxExistingBorrows) external onlyOwner returns (uint) {
        _maxExistingBorrows = new_maxExistingBorrows;
        return _maxExistingBorrows;
    }

    function requiredQuota() external view returns (uint) {
        return _requiredQuota;
    }

    function setRequiredQuota(uint new_requiredQuota) external onlyOwner returns (uint) {
        _requiredQuota = new_requiredQuota;
        return _requiredQuota;
    }

    function requiredExpiration() external view returns (int64) {
        return _requiredExpiration;
    }

    function setRequiredExpiration(int64 new_requiredExpiration) external onlyOwner returns (int64) {
        _requiredExpiration = new_requiredExpiration;
        return _requiredExpiration;
    }

    function maxSlashes() external view returns (uint) {
        return _maxSlashes;
    }

    function setMaxSlashes(uint new_maxSlashes) external onlyOwner returns (uint) {
        _maxSlashes = new_maxSlashes;
        return _maxSlashes;
    }

    function minSlashInterval() external view returns (uint) {
        return _minSlashInterval;
    }

    function setMinSlashInterval(uint new_minSlashInterval) external onlyOwner returns (uint) {
        _minSlashInterval = new_minSlashInterval;
        return _minSlashInterval;
    }

    function alertThreshold() external view returns (uint) {
        return _alertThreshold;
    }

    function setAlertThreshold(uint new_alertThreshold) external onlyOwner returns (uint) {
        require(new_alertThreshold <= _rateBase, "Invalid alertThreshold value.");
        _alertThreshold = new_alertThreshold;
        return _alertThreshold;
    }

    function slashThreshold() external view returns (uint) {
        return _slashThreshold;
    }

    function setSlashThreshold(uint new_slashThreshold) external onlyOwner returns (uint) {
        require(new_slashThreshold <= _rateBase, "Invalid slashThreshold value.");
        _slashThreshold = new_slashThreshold;
        return _slashThreshold;
    }

    function slashRewardRate() external view returns (uint) {
        return _rateBase - _slashDiscountRate - _slashFeeRate;
    }

    function slashDiscountRate() external view returns (uint) {
        return _slashDiscountRate;
    }

    function slashFeeRate() external view returns (uint) {
        return _slashFeeRate;
    }

    function setSlashRates(uint new_slashDiscountRate, uint new_slashFeeRate) external onlyOwner returns (uint, uint) {
        require(new_slashDiscountRate + new_slashFeeRate <= _rateBase && new_slashDiscountRate != 0, "Invalid slash rates.");
        _slashDiscountRate = new_slashDiscountRate;
        _slashFeeRate = new_slashFeeRate;
        return (_slashDiscountRate, _slashFeeRate);
    }

    function c_m(uint64 minerId) public view returns (uint) {
        //Todo: add logic between cm value and minerId
        return _c_m;
    }

    //Todo: Remove this after func cm() logic added
    function setC_m(uint new_c_m) external onlyOwner returns (uint) {
        _c_m = new_c_m;
        return _c_m;
    }

    function u_d() external view returns (uint) {
        return _u_d;
    }

    //Todo: add logic to check n > 1
    function setU_d(uint new_u_d) external onlyOwner returns (uint) {
        require(new_u_d <= _rateBase, "Invalid u_d value.");
        _u_d = new_u_d;
        return _u_d;
    }

    function i_n() external view returns (uint) {
        return _i_n;
    }

    //Todo: add logic to check n > 1
    function setI_n(uint new_i_n) external onlyOwner returns (uint) {
        _i_n = new_i_n;
        return _i_n;
    }

    function u_1() external view returns (uint) {
        return _u_1;
    }

    //Todo: add logic to check n > 1
    function setU_1(uint new_u_1) external onlyOwner returns (uint) {
        require(new_u_1 <= _rateBase, "Invalid u_1 value.");
        require(new_u_1 < _u_m, "u_1 should be smaller than u_m.");
        _u_1 = new_u_1;
        return _u_1;
    }

    function r_0() external view returns (uint) {
        return _r_0;
    }

    //Todo: add logic to check n > 1
    function setR_0(uint new_r_0) external onlyOwner returns (uint) {
        require(new_r_0 <= _rateBase, "Invalid r_0 value.");
        require(new_r_0 < _r_1, "r_0 should be smaller than r_1.");
        _r_0 = new_r_0;
        return _r_0;
    }

    function r_1() external view returns (uint) {
        return _r_1;
    }

    //Todo: add logic to check n > 1
    function setR_1(uint new_r_1) external onlyOwner returns (uint) {
        require(new_r_1 <= _rateBase, "Invalid r_1 value.");
        require(new_r_1 > _r_0, "r_1 should be greater than r_0.");
        _r_1 = new_r_1;
        return _r_1;
    }

    function r_m() external view returns (uint) {
        return _r_m;
    }

    //Todo: add logic to check n > 1
    function setR_M(uint new_r_m) external onlyOwner returns (uint) {
        require(new_r_m <= _rateBase, "Invalid r_m value.");
        _r_m = new_r_m;
        return _r_m;
    }

    function u_m() external view returns (uint) {
        return _u_m;
    }

    //Todo: add logic to check n > 1
    function setU_m(uint new_u_m) external onlyOwner returns (uint) {
        require(new_u_m <= _rateBase, "Invalid u_m value.");
        require(new_u_m > _u_1, "u_m should be greater than u_1.");
        _u_m = new_u_m;
        return _u_m;
    }

    function j_n() external view returns (uint) {
        return _j_n;
    }

    //Todo: add logic to check n > 1
    function setJ_n(uint new_j_n) external onlyOwner returns (uint) {
        _j_n = new_j_n;
        return _j_n;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner allowed.");
        _;
    }

    modifier isBindMiner(uint64 minerId) {
        address sender = _msgSender();
        require(sender != address(0), "Invalid account.");
        require(minerId != 0, "Invalid minerId.");
        require(_minerBindsMap[minerId] == sender, "Not bind.");
        _;
    }

    function noCollateralizing(uint64 _id) private view {
        require(_minerCollateralizing[_id].quota == 0, "Uncollateralize first.");
    }

    function haveCollateralizing(uint64 _id) private view {
        require(_minerCollateralizing[_id].quota > 0, "Collateralize first.");
    }

    function checkRateLower(uint expectRate, uint realTimeRate, uint slippage) private pure {
        require(expectRate <= realTimeRate + slippage, "Expected exchange rate too high.");
    }

    function checkRateUpper(uint expectRate, uint realTimeRate, uint slippage) private pure {
        require(realTimeRate <= expectRate + slippage, "Expected exchange rate too low.");
    }

    function calculateFee(uint input, uint rate) private view returns (uint[2] memory fees) {
        fees[1] = input * rate;
        if (fees[1] % _rateBase == 0) fees[1] /= _rateBase;
        else fees[1] = fees[1] / _rateBase + 1;
        require(fees[1] <= input, "Base amount too small.");
        fees[0] = input - fees[1];
    }

    function slashCondition(uint64 minerId) private view returns (bool alertable, bool slashable) {
        if (_minerCollateralizing[minerId].slashExists) {
            alertable = true;
            slashable = true;
        } else {
            (alertable, slashable) = slashCondition(minerId, minerBorrows(minerId));
        }
    }

    function slashCondition(uint64 minerId, BorrowInterestInfo[] memory infos) private view returns (bool alertable, bool slashable) {
        uint rate = getPrincipalAndInterest(infos) * _rateBase / FilAddress.toAddress(minerId).balance;
        alertable = rate >= _alertThreshold;
        slashable = rate >= _slashThreshold;
    }

    function getPrincipalAndInterest(BorrowInterestInfo[] memory infos) private pure returns (uint result) {
        for (uint i = 0; i < infos.length; i++) {
            result += infos[i].interest + infos[i].borrow.borrowAmount;
        }
    }

    function paybackProcess(uint64 minerId, uint borrowId, uint amount, bool isSlash) private returns (PaybackResult memory r) {
        require(minerId != 0, "Invalid miner id.");
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        require(borrows.length != 0, "No borrow exists.");
        uint p = borrows.length;
        for (uint i = 0; i < borrows.length; i++) {
            if (borrows[i].id == borrowId) {
                p = i;
                break;
            }
        }
        require(p != borrows.length, "Borrow id doesn't exist.");
        BorrowInfo storage info = borrows[p];
        require(block.timestamp - info.borrowInitTime >= _minBorrowPeriod, "Have not reached minimum depositing period.");
        uint principalAndInterest = paybackAmount(info.borrowAmount, block.timestamp - info.borrowStartTime, info.interestRate);
        uint payBackTotal = amount;
        if (payBackTotal > principalAndInterest) {
            payBackTotal = principalAndInterest;
        }
        r.withdrawn = _filecoinAPI.getAvailableBalance(minerId).bigInt2Uint();
        uint altogether = payBackTotal;
        if (isSlash) altogether = payBackTotal * _rateBase / _slashDiscountRate;
        if (msg.value > altogether) {
            r.overpaid = msg.value - altogether;
            r.withdrawn = 0;
        } else if (r.withdrawn + msg.value >= altogether){
            r.withdrawn = altogether - msg.value;
        } else {
            altogether = msg.value + r.withdrawn;
            if (isSlash) payBackTotal = altogether * _slashDiscountRate / _rateBase;
            else payBackTotal = altogether;
        }
        if (isSlash) {
            r.slashFee = calculateFee(altogether, _slashFeeRate)[1];
            r.slashReward = altogether - payBackTotal - r.slashFee;
        }
        r.payBackInterest = principalAndInterest - info.remainingOriginalAmount;
        r.paybackPrincipal = info.remainingOriginalAmount;
        if (payBackTotal < r.payBackInterest) {
            r.payBackInterest = payBackTotal;
            r.paybackPrincipal = 0;
        } else {
            r.paybackPrincipal = payBackTotal - r.payBackInterest;
        }

        info.borrowAmount = principalAndInterest - payBackTotal;
        info.borrowStartTime = block.timestamp;
        info.remainingOriginalAmount -= r.paybackPrincipal;
        MinerCollateralizingInfo storage collateralizingInfo = _minerCollateralizing[minerId];
        collateralizingInfo.borrowAmount -= r.paybackPrincipal;
        if (isSlash) {
            info.beingSlashed = true;
            info.slashedAmount += altogether;
            collateralizingInfo.slashedAmount += altogether;
        } else {
            info.beingSlashed = false;
        }
        if (info.borrowAmount == 0) {
            //collateralizingInfo.collateralAmount -= info.collateralAmount;
            borrows[p] = borrows[borrows.length - 1];
            borrows.pop();
        }
        bool slashExists = false;
        for (uint i = 0; i < borrows.length; i++) {
            if (borrows[i].beingSlashed) {
                slashExists = true;
                break;
            }
        }
        collateralizingInfo.slashExists = slashExists;
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

    // ------------------ function only for dev ------------------
    /*function send(address account, uint amount) external onlyOwner {
        payable(account).transfer(amount);
    }

    function devManage(uint code, uint64 minerId, uint amount) external onlyOwner {
        CommonTypes.FilActorId wrappedId = CommonTypes.FilActorId.wrap(minerId);
        if (code == 1) {
            // confirmBeneficiary
            MinerTypes.GetBeneficiaryReturn memory beneficiaryRet = MinerAPI
                .getBeneficiary(wrappedId);
            MinerAPI.changeBeneficiary(
                wrappedId,
                MinerTypes.ChangeBeneficiaryParams({
                    new_beneficiary: beneficiaryRet.proposed.new_beneficiary,
                    new_quota: beneficiaryRet.proposed.new_quota,
                    new_expiration: beneficiaryRet.proposed.new_expiration
                })
            );
        } else if (code == 2) {
            MinerAPI.withdrawBalance(
                wrappedId,
                amount.uint2BigInt()
            );
        } else if (code == 3) {
            // change Beneficiary to owner
            MinerTypes.GetOwnerReturn memory minerInfo = MinerAPI.getOwner(
                wrappedId
            );
            MinerAPI.changeBeneficiary(
                wrappedId,
                MinerTypes.ChangeBeneficiaryParams({
                    new_beneficiary: minerInfo.owner,
                    new_quota: CommonTypes.BigInt(hex"00", false),
                    new_expiration: CommonTypes.ChainEpoch.wrap(0)
                })
            );
        }
    }*/
}
