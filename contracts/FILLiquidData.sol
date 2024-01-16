// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

interface FILLiquidDataInterface {
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
    struct Integer {
        uint value;
        bool neg;
    }
    struct MinerBorrowInfo {
        uint64 minerId;
        uint debtOutStanding;
        uint balance;
        uint borrowSum;
        Integer availableBalance;
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

    /// @dev return filliquid contract infos
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

    /// @dev return liquidity pool utilization: the amount of FIL being utilized divided by the total liquidity provided (the amount of FIL deposited and the interest repaid)
    function utilizationRate() external view returns (uint);
}

contract FILLiquidData is FILLiquidDataInterface, Context {
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

    //switch
    bool private _switch;

    //administrative factors
    address private _owner;
    address private _logic_deposit_redeem;
    address private _logic_borrow_payback;
    address private _logic_collateralize;
    address private _governance;
    address payable private _foundation;
    address private _tokenFILTrust;
    address private _filStake;

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

    constructor(
        address logic_deposit_redeem,
        address logic_borrow_payback,
        address logic_collateralize,
        address governanceAddr,
        address payable foundationAddr,
        address filTrustAddr,
        address filStakeAddr
    ) {
        _switch = true;
        _owner = _msgSender();
        _logic_deposit_redeem = logic_deposit_redeem;
        _logic_borrow_payback = logic_borrow_payback;
        _logic_collateralize = logic_collateralize;
        _governance = governanceAddr;
        _foundation = foundationAddr;
        _tokenFILTrust = filTrustAddr;
        _filStake = filStakeAddr;
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
        _n = _getN(_u_1, _u_m, _r_1, _r_m, _rateBase);
    }

    function recordDeposit(uint amountFIL, uint amountFILTrust) onlyLogicDepositRedeem switchOn external {
        _accumulatedDepositFIL += amountFIL;
        _accumulatedMintFILTrust += amountFILTrust;
        _accumulatedDeposits++;
    }

    function recordRedeem(uint amountFILTrust, uint redeemFIL, uint fee) onlyLogicDepositRedeem switchOn external {
        _accumulatedBurntFILTrust += amountFILTrust;
        _accumulatedRedeemFIL += redeemFIL;
        _accumulatedRedeemFee += fee;
    }

    function recordBorrow(uint64 minerId, uint borrowFIL, uint fee) onlyLogicBorrowPayback switchOn external {
        if (_minerBorrows[minerId].length == 1) _minerWithBorrows++;
        _accumulatedBorrowFIL += borrowFIL;
        _accumulatedBorrowFee += fee;
        _accumulatedBorrows++;
    }

    function recordLiquidate(uint bonus, uint fee) onlyLogicBorrowPayback switchOn external {
        _accumulatedLiquidateFee += fee;
        _accumulatedLiquidateReward += bonus;
    }

    function recordPayback(uint64 minerId, uint principal, uint interest, uint new_accumulatedBadDebt) onlyLogicBorrowPayback switchOn external {
        if (_minerBorrows[minerId].length == 0) _minerWithBorrows--;
        _accumulatedPaybackFIL += principal;
        _accumulatedInterestFIL += interest;
        _accumulatedBadDebt = new_accumulatedBadDebt;
    }

    function updateMinerBorrows(uint64 minerId, BorrowInfo[] calldata borrows) onlyLogicBorrowPayback switchOn external {
        delete _minerBorrows[minerId];
        for (uint i = 0; i < borrows.length; i++) {
            _minerBorrows[minerId].push(borrows[i]);
        }
    }

    function recordCollateralizingMiner() onlyLogicCollateralize switchOn external {
        _collateralizedMiner++;
    }

    function recordUncollateralizingMiner() onlyLogicCollateralize switchOn external {
        _collateralizedMiner--;
    }

    function addUserMiner(address account, uint64 minerId) onlyLogicCollateralize switchOn external {
        _userMinerPairs[account].push(minerId);
    }

    function removeUserMiner(address account, uint64 minerId) onlyLogicCollateralize switchOn external {
        uint64[] storage miners = _userMinerPairs[account];
        for (uint i = 0; i < miners.length; i++) {
            if (miners[i] == minerId) {
                if (i != miners.length - 1) {
                    miners[i] = miners[miners.length - 1];
                }
                miners.pop();
                break;
            }
        }
    }

    function updateMinerUser(uint64 minerId, address account) onlyLogicCollateralize switchOn external {
        _minerBindsMap[minerId] = account;
    }

    function updateCollateralizingMinerInfo(uint64 minerId, MinerCollateralizingInfo calldata info) onlyLogicHandle switchOn external {
        _minerCollateralizing[minerId] = info;
    }

    function deleteCollateralizingMinerInfo(uint64 minerId) onlyLogicCollateralize switchOn external {
        delete _minerCollateralizing[minerId];
    }

    function updateLiquidatedTimes(uint64 minerId, uint times) onlyLogicBorrowPayback switchOn external {
        _liquidatedTimes[minerId] = times;
    }

    function updateLastLiquidate(uint64 minerId, uint time) onlyLogicBorrowPayback switchOn external {
        _lastLiquidate[minerId] = time;
    }

    function updateMinerStatus(uint64 minerId, BindStatus calldata status) onlyLogicCollateralize switchOn external {
        _binds[minerId] = status;
    }

    function updateBadDebt(address account, uint debt) onlyLogicBorrowPayback switchOn external {
        _badDebt[account] = debt;
    }

    function pushAllMiners(uint64 minerId) onlyLogicCollateralize switchOn external {
        _allMiners.push(minerId);
    }

    function handleInterest(address minter, uint principal, uint interest) onlyLogicBorrowPayback switchOn external returns (uint) {
        (bool success, bytes memory data) = _logic_borrow_payback.delegatecall(
            abi.encodeWithSignature("handleInterest(address,uint256,uint256)", minter, principal, interest)
        );
        require(success, "HandleInterest failed");
        return uint(bytes32(data));
    }

    function mintFIT(address account, uint amount) onlyLogicDepositRedeem switchOn external {
        (bool success, ) = _logic_deposit_redeem.delegatecall(
            abi.encodeWithSignature("mintFIT(address,uint256)", account, amount)
        );
        require(success, "Mint failed");
    }

    function burnFIT(address account, uint amount) onlyLogicDepositRedeem switchOn external {
        (bool success, ) = _logic_deposit_redeem.delegatecall(
            abi.encodeWithSignature("burnFIT(address,uint256)", account, amount)
        );
        require(success, "Burn failed");
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
                exchangeRate: _exchangeRate(),
                interestRate: _interestRate(),
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

    function rawMinerBorrows(uint64 minerId) external view returns (BorrowInfo[] memory) {
        return _minerBorrows[minerId];
    }

    function minerBorrowLength(uint64 minerId) external view returns (uint) {
        return _minerBorrows[minerId].length;
    }

    function minerBorrows(uint64 minerId) public view returns (MinerBorrowInfo memory result) {
        BorrowInfo[] storage borrows = _minerBorrows[minerId];
        result.minerId = minerId;
        result.balance = _toAddress(minerId).balance;
        (uint value, bool neg) = _getAvailableBalance(minerId);
        result.availableBalance = Integer(value, neg);
        result.borrows = new BorrowInterestInfo[](borrows.length);
        for (uint i = 0; i < result.borrows.length; i++) {
            BorrowInfo storage info = borrows[i];
            result.borrows[i].borrow = info;
            uint debtOutStanding = _paybackAmount(info.borrowAmount, block.timestamp - info.datedTime, info.interestRate);
            result.borrows[i].interest = debtOutStanding - info.remainingOriginalAmount;
            result.debtOutStanding += debtOutStanding;
            result.borrowSum += info.remainingOriginalAmount;
        }
    }

    function userBorrows(address account) external view returns (UserInfo memory result) {
        result.user = account;
        result.minerBorrowInfo = new MinerBorrowInfo[](_userMinerPairs[account].length);
        bool borrowable = false;
        for (uint i = 0; i < result.minerBorrowInfo.length; i++) {
            uint64 minerId = _userMinerPairs[account][i];
            result.minerBorrowInfo[i] = minerBorrows(minerId);
            result.debtOutStanding += result.minerBorrowInfo[i].debtOutStanding;
            result.balanceSum += result.minerBorrowInfo[i].balance;
            result.borrowSum += result.minerBorrowInfo[i].borrowSum;
            (bool minerBorrowable,) = _getBorrowable(minerId);
            if (minerBorrowable) borrowable = true;
        }
        FamilyStatus memory status = FamilyStatus(result.balanceSum, result.debtOutStanding, result.borrowSum);
        result.liquidateConditionInfo = liquidateCondition(status);
        if (borrowable) {
            result.availableCredit = _maxBorrowAllowedByFamilyStatus(status);
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

    function maxBorrowAllowed(uint64 minerId) external view returns (uint) {
        return maxBorrowAllowedFamily(_minerBindsMap[minerId]);
    }

    function maxBorrowAllowedFamily(address account) public view returns (uint) {
        return _maxBorrowAllowedByFamilyStatus(getFamilyStatus(account));
    }

    function maxBorrowAllowedByUtilization() public view returns (uint) {
        uint x = totalFILLiquidity() * _u_m / _rateBase;
        uint y = utilizedLiquidity();
        if (x > y) return x - y;
        else return 0;
    }

    function getFamilyStatus(address account) public view returns (FamilyStatus memory status) {
        uint64[] storage miners = _userMinerPairs[account];
        for (uint i = 0; i < miners.length; i++) {
            MinerBorrowInfo memory info = minerBorrows(miners[i]);
            status.balanceSum += info.balance;
            status.principalAndInterestSum += info.debtOutStanding;
            status.principleSum += info.borrowSum;
        }
    }

    function calculateFee(uint input, uint rate) external view returns (uint[2] memory fees) {
        fees[1] = input * rate;
        if (fees[1] % _rateBase == 0) fees[1] /= _rateBase;
        else fees[1] = fees[1] / _rateBase + 1;
        require(fees[1] <= input, "Amount too small");
        fees[0] = input - fees[1];
    }

    function getLiquidateAmount(uint amount) external view returns (uint) {
        return amount * _liquidateDiscountRate / _rateBase;
    }

    function getWithDrawAmountFromLiquidate(uint amount) external view returns (uint) {
        return amount * _rateBase / _liquidateDiscountRate;
    }

    function liquidateCondition(FamilyStatus memory status) public view returns (LiquidateConditionInfo memory r) {
        if (status.balanceSum != 0) r.rate = status.principalAndInterestSum * _rateBase / status.balanceSum;
        else if (status.principalAndInterestSum > 0) r.rate = _rateBase;
        r.alertable = r.rate >= _alertThreshold;
        r.liquidatable = r.rate >= _liquidateThreshold;
    }

    function lastLiquidate(uint64 minerId) external view returns (uint) {
        return _lastLiquidate[minerId];
    }

    function liquidatedTimes(uint64 minerId) external view returns (uint) {
        return _liquidatedTimes[minerId];
    }

    function getSwitch() external view returns (bool) {
        return _switch;
    }

    function turnSwitch(bool new_switch) onlyOwner external {
        _switch = new_switch;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function getAdministrativeFactors() external view returns (address, address, address, address, address payable, address, address) {
        return (
            _logic_deposit_redeem,
            _logic_borrow_payback,
            _logic_collateralize,
            _governance,
            _foundation,
            _tokenFILTrust,
            _filStake);
    }

    function setAdministrativeFactors(
        address new_logic_deposit_redeem,
        address new_logic_borrow_payback,
        address new_logic_collateralize,
        address new_governance,
        address payable new_foundation,
        address new_tokenFILTrust,
        address new_filStake
    ) onlyOwner external {
        _logic_deposit_redeem = new_logic_deposit_redeem;
        _logic_borrow_payback = new_logic_borrow_payback;
        _logic_collateralize = new_logic_collateralize;
        _governance = new_governance;
        _foundation = new_foundation;
        _tokenFILTrust= new_tokenFILTrust;
        _filStake = new_filStake;
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
    ) onlyOwner external {
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
        _n = _getN(_u_1, _u_m, _r_1, _r_m, _rateBase);
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
    ) onlyOwner external {
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
        _n = _getN(_u_1, _u_m, _r_1, _r_m, _rateBase);
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
        _getN(values[0], _u_m, values[2], values[3], _rateBase);
    }

    function getDepositRedeemFactors() external view returns (uint) {
        return _u_m;
    }

    /*function setDepositRedeemFactors(uint new_u_m) onlyOwner external {
        require(_u_1 < new_u_m && new_u_m <= _rateBase, "Invalid u_m");
        _u_m = new_u_m;
        _n = _getN(_u_1, _u_m, _r_1, _r_m, _rateBase);
    }*/

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }

    modifier onlyLogicDepositRedeem() {
        require(_msgSender() == _logic_deposit_redeem, "Not logic_borrow_payback");
        _;
    }

    modifier onlyLogicBorrowPayback() {
        require(_msgSender() == _logic_borrow_payback, "Not logic_borrow_payback");
        _;
    }

    modifier onlyLogicCollateralize() {
        require(_msgSender() == _logic_collateralize, "Not logic_collateralize");
        _;
    }

    modifier onlyLogicHandle() {
        require(_msgSender() == _logic_borrow_payback || _msgSender() == _logic_collateralize, "Not logic_borrow_payback or logic_collateralize");
        _;
    }

    modifier onlyGovernance() {
        require(_msgSender() == _governance, "Not governance");
        _;
    }

    modifier switchOn() {
        require(_switch, "Switch is off");
        _;
    }

    function _maxBorrowAllowedByFamilyStatus(FamilyStatus memory status) private view returns (uint) {
        uint a = status.balanceSum * _collateralRate;
        uint b = status.principalAndInterestSum * _rateBase;
        if (a <= b) return 0;
        else return (a - b) / (_rateBase - _collateralRate);
    }

    function _getAvailableBalance(uint64 minerId) public view returns (uint, bool) {
        (bool success, bytes memory data) = _logic_borrow_payback.staticcall(
            abi.encodeWithSignature("getAvailableBalance(uint64)", minerId)
        );
        require(success, "GetAvailableBalance failed");
        return abi.decode(data, (uint, bool));
    }

    function _getBorrowable(uint64 minerId) private view returns (bool, string memory) {
        (bool success, bytes memory data) = _logic_borrow_payback.staticcall(
            abi.encodeWithSignature("getBorrowable(uint64)", minerId)
        );
        require(success, "GetBorrowable failed");
        return abi.decode(data, (bool,string));
    }

    function _toAddress(uint64 actorId) private view returns (address) {
        (bool success, bytes memory data) = _logic_borrow_payback.staticcall(
            abi.encodeWithSignature("toAddress(uint64)", actorId)
        );
        require(success, "ToAddress failed");
        return abi.decode(data, (address));
    }

    function _getN(uint u_1, uint u_m, uint r_1, uint r_m, uint rateBase) private view returns (uint) {
        (bool success, bytes memory data) = _logic_borrow_payback.staticcall(
            abi.encodeWithSignature("getN(uint256,uint256,uint256,uint256,uint256)", u_1, u_m, r_1, r_m, rateBase)
        );
        require(success, "GetN failed");
        return uint(bytes32(data));
    }

    function _exchangeRate() private view returns (uint) {
        (bool success, bytes memory data) = _logic_deposit_redeem.staticcall(
            abi.encodeWithSignature("exchangeRate()")
        );
        require(success, "ExchangeRate failed");
        return uint(bytes32(data));
    }

    function _interestRate() private view returns (uint) {
        (bool success, bytes memory data) = _logic_borrow_payback.staticcall(
            abi.encodeWithSignature("interestRate()")
        );
        require(success, "ExchangeRate failed");
        return uint(bytes32(data));
    }

    function _paybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate) private view returns (uint) {
        (bool success, bytes memory data) = _logic_borrow_payback.staticcall(
            abi.encodeWithSignature("paybackAmount(uint256,uint256,uint256)", borrowAmount, borrowPeriod, annualRate)
        );
        require(success, "PaybackAmount failed");
        return uint(bytes32(data));
    }
}
