// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./FILGovernance.sol";

contract FIGStake is Context{
    // 一次分红，每次receive方法呗调用的时候，增加一个bonus
    struct Bonus {
        uint totalAmount;
        uint releasedAmount;
        uint totalStakedPower;
        uint totalStakedFIG;
        uint height;
    }
    struct Bonuses {
        Bonus[] bonuses;
    }
    struct Stake {
        uint stakeId;
        uint amount;
        uint rate;
        uint start;
        uint duration;
        uint end;
        uint nextBonusIndex;
        uint haveReleased;
        bool haveUnstaked;
    }
    struct StakerStatus {
        uint stakeSum;
        uint powerSum;
        Stake[] stakes;
    }
    struct StakeInfo {
        Stake stake;
        uint withdrawStatus; //0: cannot be withdrawn, 1: can be withdrawn and have not been withdrawn, 2: have been withdrawn
        uint releasableAmount;
    }
    struct StakerInfo {
        address staker;
        uint stakeSum;
        uint powerSum;
        uint withdrawableSum;
        uint releasableSum;
        StakeInfo[] stakeInfos;
    }
    struct FIGStakeInfo {
        uint accumulatedBonus;
        uint accumulatedReleasedBonus;
        uint accumulatedStake;
        uint accumulatedWithdrawn;
        uint accumulatedPowerIn;
        uint accumulatedPowerOut;
        uint totalPower;
        uint lastConfirmedPower;
        uint lastConfirmedHeight;
        uint pendingPowerIn;
        uint pendingPowerOut;
        uint pendingHeight;
        uint nextStakeId;
    }
    struct StakeRate {
        uint stakePeriod;
        uint rate;
    }
    struct StakeRates {
        StakeRate[] stakeRates;
    }
    event BonusReceived(
        address indexed foundation,
        uint indexed bonusIndex,
        uint totalAmount,
        uint totalStakedPower,
        uint totalStakedFIG
    );
    event Staked(
        address indexed staker,
        uint indexed stakeId,
        uint amount,
        uint rate,
        uint start,
        uint duration
    );
    event Unstaked(
        address indexed staker,
        uint indexed stakeId,
        uint amount,
        uint rate,
        uint start,
        uint duration,
        uint end
    );
    event BonusReleased(
        address indexed staker,
        uint indexed stakeId,
        uint indexed bonusIndex,
        uint stakeAmount,
        uint bonusAmount
    );

    Bonuses private _bonuses;
    StakeRates private _stakeRates;
    mapping(address => StakerStatus) private _stakerStakes;
    mapping(address => bool) private _onceStaked;
    mapping(uint => address) private _idStaker;
    mapping(uint => uint) private _stakeAmounts;
    address[] private _stakers;
    address private _owner;
    FILGovernance private _tokenFILGovernance;
    address private _foundation;

    uint private _accumulatedBonus;
    uint private _accumulatedReleasedBonus;
    uint private _accumulatedStake;
    uint private _accumulatedWithdrawn;
    uint private _accumulatedPowerIn;
    uint private _accumulatedPowerOut;
    uint private _totalPower;
    uint private _lastConfirmedPower;
    uint private _lastConfirmedHeight;
    uint private _pendingPowerIn;
    uint private _pendingPowerOut;
    uint private _pendingHeight;
    uint private _nextStakeId;

    uint private _minStake;
    uint private _maxStakesPerStaker;

    uint constant DEFAULT_MIN_STAKE = 1 ether;
    uint constant DEFAULT_MAX_STAKES_PER_STAKER = 100;
    uint constant RATE_BASE = 1000000;
    uint constant STAKE_PERIOD_0 = 0;
    uint constant STAKE_RATE_0 = 1;
    uint constant STAKE_PERIOD_1 = 86400; //30 days
    uint constant STAKE_RATE_1 = 2;
    uint constant STAKE_PERIOD_2 = 259200; //90 days
    uint constant STAKE_RATE_2 = 3;
    uint constant STAKE_PERIOD_3 = 518400; //180 days
    uint constant STAKE_RATE_3 = 4;
    uint constant STAKE_PERIOD_4 = 777600; //270 days
    uint constant STAKE_RATE_4 = 5;
    uint constant STAKE_PERIOD_5 = 1036800; //360 days
    uint constant STAKE_RATE_5 = 6;

    constructor(address tokenFILGovernance, address foundation) {
        _owner = _msgSender();
        _tokenFILGovernance = FILGovernance(tokenFILGovernance);
        _foundation = foundation;
        _minStake = DEFAULT_MIN_STAKE;
        _maxStakesPerStaker = DEFAULT_MAX_STAKES_PER_STAKER;
        _lastConfirmedHeight = block.number - 1;
        _pendingHeight = block.number;
        uint[] memory stakePeriods = new uint[](6);
        stakePeriods[0] = STAKE_PERIOD_0;
        stakePeriods[1] = STAKE_PERIOD_1;
        stakePeriods[2] = STAKE_PERIOD_2;
        stakePeriods[3] = STAKE_PERIOD_3;
        stakePeriods[4] = STAKE_PERIOD_4;
        stakePeriods[5] = STAKE_PERIOD_5;
        uint[] memory rates = new uint[](6);
        rates[0] = STAKE_RATE_0;
        rates[1] = STAKE_RATE_1;
        rates[2] = STAKE_RATE_2;
        rates[3] = STAKE_RATE_3;
        rates[4] = STAKE_RATE_4;
        rates[5] = STAKE_RATE_5;
        resetStakeRates(stakePeriods, rates);
    }

    // todo(xk): redeem&borrow&liquid fee，manager不一定往这个合约deposit
    receive() onlyFoundation external payable {
        uint index = getNextBonusIndex();
        uint amount = msg.value;
        _accumulatedBonus += amount;
        _updateData();
        uint totalStakedFIG = _accumulatedStake - _accumulatedWithdrawn;
        _bonuses.bonuses.push(Bonus(amount, 0, _totalPower, totalStakedFIG, block.number));
        emit BonusReceived(_foundation, index, amount, _totalPower, totalStakedFIG);
        _totalPower = 0;
    }

    // 这个maxStart有效期。
    function stakeFilGovernance(uint amount, uint maxStart, uint stakeProgram) external returns (uint stakeId) {
        require(amount >= _minStake, "Amount too small");
        uint start = block.number;
        require(maxStart == 0 || start <= maxStart, "Block height exceeds");
        require(stakeProgram < _stakeRates.stakeRates.length, "Invalid stake program");
        address staker = _msgSender();
        StakerStatus storage status = _stakerStakes[staker];
        Stake[] storage stakes = status.stakes;
        require(stakes.length < _maxStakesPerStaker, "Exceed max stakes");
        StakeRate storage stakeRate = _stakeRates.stakeRates[stakeProgram];
        uint duration = stakeRate.stakePeriod;
        uint rate = stakeRate.rate;

        // todo(xk): approve
        _tokenFILGovernance.transferFrom(staker, address(this), amount);
        _updateData();
        uint power = _getStakePower(amount, rate);
        stakeId = _nextStakeId;
        status.stakeSum += amount;
        status.powerSum += power;
        _idStaker[stakeId] = staker;
        if (!_onceStaked[staker]) _stakers.push(staker);
        _onceStaked[staker] = true;
        _pendingPowerIn += power;
        _stakeAmounts[duration] += amount;
        _accumulatedStake += amount;
        _accumulatedPowerIn += power;
        stakes.push(
            Stake({
                stakeId: stakeId,
                amount: amount,
                rate: rate,
                start: start,
                duration: duration,
                end: 0,
                // todo(xk): 这里nextBonusIndex是不是应该是从0开始，这里好像从-1开始
                nextBonusIndex: getNextBonusIndex(),
                haveReleased: 0,
                haveUnstaked: false
            })
        );
        _nextStakeId++;
        emit Staked(staker, stakeId, amount, rate, start, duration);
    }

    function unStakeFilGovernance(uint stakeId) external {
        address staker = _msgSender();
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        uint pos = _getStakePos(staker, stakeId);
        Stake storage stake = stakes[pos];
        require(block.number >= stake.end, "Stake not withdrawable");
        _updateData();

        uint powerOut = _getStakePower(stake.amount, stake.rate);

        _stakerStakes[staker].stakeSum -= stake.amount;
        _stakerStakes[staker].powerSum -= powerOut;
        _tokenFILGovernance.transfer(staker, stake.amount);
        _pendingPowerOut += powerOut;
        _stakeAmounts[stake.duration] -= stake.amount;
        _accumulatedWithdrawn += stake.amount;
        _accumulatedPowerOut += powerOut;
        stake.haveUnstaked = true;
        stake.end = block.number;
        emit Unstaked(staker, stake.stakeId, stake.amount, stake.rate, stake.start, stake.duration, stake.end);
        if (stake.nextBonusIndex == getNextBonusIndex()) {
            stakes[pos] = stakes[stakes.length - 1];
            stakes.pop();
        }
    }

    function canReleaseBonus(uint stakeId, uint bonusIndex) external view returns (bool canRelease, uint amount) {
        require(bonusIndex < getNextBonusIndex(), "Invalid bonus index");
        address staker = _idStaker[stakeId];
        uint pos = _getStakePos(staker, stakeId);
        Stake storage stake = _stakerStakes[staker].stakes[pos];
        canRelease = _canReleaseBonusAt(stake.nextBonusIndex, bonusIndex);
        amount = _getReleaseBonusAmount(stake, bonusIndex);
    }

    function releaseBonus(uint stakeId, uint bonusIndex) external returns (uint released) {
        require(bonusIndex < getNextBonusIndex(), "Invalid bonus index");
        address staker = _msgSender();
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        uint pos = _getStakePos(staker, stakeId);
        Stake storage stake = stakes[pos];
        require(_canReleaseBonusAt(stake.nextBonusIndex, bonusIndex), "Cannot release this bonus for the stake");
        for (uint i = stake.nextBonusIndex; i <= bonusIndex; i++) {
            released += _getReleaseBonusAmount(stake, i);
            _bonuses.bonuses[i].releasedAmount += released;
        }
        stake.nextBonusIndex = bonusIndex + 1;
        if (released > 0) {
            _accumulatedReleasedBonus += released;
            stake.haveReleased += released;
            payable(staker).transfer(released);
        }
        emit BonusReleased(staker, stake.stakeId, bonusIndex, stake.amount, released);
        // todo(xk): unstaked && (released || unstaked)
        if (stake.haveUnstaked && (stake.nextBonusIndex == getNextBonusIndex() || stake.end <= _bonuses.bonuses[bonusIndex].height)) {
            stakes[pos] = stakes[stakes.length - 1];
            stakes.pop();
        }
    }

    function releaseBonus4AllStakes(uint bonusIndex) public returns (uint released) {
        require(bonusIndex < getNextBonusIndex(), "Invalid bonus index");
        return _releaseBonus4AllStakes(bonusIndex);
    }

    function releaseBonusAll() external returns (uint released) {
        uint nextBonusIndex = getNextBonusIndex();
        require(nextBonusIndex > 0, "No bonus to release");
        return _releaseBonus4AllStakes(nextBonusIndex - 1);
    }

    function getNextBonusIndex() public view returns (uint) {
        return _bonuses.bonuses.length;
    }

    function getBonus(uint bonusIndex) external view returns (Bonus memory) {
        return _bonuses.bonuses[bonusIndex];
    }

    function getStakeRatesLength() public view returns (uint length) {
        return _stakeRates.stakeRates.length;
    }

    function getStakeRates() public view returns (StakeRates memory) {
        return _stakeRates;
    }

    function getStakeRatesSingle(uint index) external view returns (StakeRate memory) {
        return _stakeRates.stakeRates[index];
    }

    function onceStaked(address staker) external view returns (bool) {
        return _onceStaked[staker];
    }

    function getStakersCount() external view returns (uint) {
        return _stakers.length;
    }

    function getStakersSubset(uint start, uint end) external view returns (StakerInfo[] memory result) {
        require(start < end && end <= _stakers.length, "Invalid indexes");
        result = new StakerInfo[](end - start);
        for (uint i = 0; i < end - start; i++) {
            result[i] = getStakerStakes(_stakers[i + start]);
        }
    }

    function getStakerStakes(address staker) public view returns (StakerInfo memory result) {
        StakerStatus storage status = _stakerStakes[staker];
        Stake[] storage stakes = status.stakes;
        result.staker = staker;
        result.stakeSum = status.stakeSum;
        result.stakeInfos = new StakeInfo[](stakes.length);
        for (uint i = 0; i < stakes.length; i++) {
            StakeInfo memory info = _getStakeInfoByPos(staker, i);
            result.stakeInfos[i] = info;
            if (info.withdrawStatus == 1) {
                result.withdrawableSum += info.stake.amount;
            }
            result.releasableSum += info.releasableAmount;
        }
    }

    function getStakerTerms(address staker) public view returns (uint figFixed, uint figVariable) {
        StakerStatus storage status = _stakerStakes[staker];
        Stake[] storage stakes = status.stakes;
        uint height = block.number;
        for (uint i = 0; i < stakes.length; i++) {
            Stake storage stake = stakes[i];
            if (height >= stake.start + stake.duration && stake.end == 0) figVariable += stakes[i].amount;
        }
        figFixed = status.stakeSum - figVariable;
    }

    function getStakerById(uint stakeId) external view returns (address) {
        return _idStaker[stakeId];
    }

    function getStakeAmounts(uint duration) external view returns (uint) {
        return _stakeAmounts[duration];
    } 

    function getStakeInfoById(uint stakeId) external view returns (StakeInfo memory) {
        return getStakeInfoByStakerAndId(_idStaker[stakeId], stakeId);
    }

    function getStakeInfoByStakerAndId(address staker, uint stakeId) public view returns (StakeInfo memory result) {
        uint pos = _getStakePos(staker, stakeId);
        return _getStakeInfoByPos(staker, pos);
    }

    function getStakerSums(address staker) external view returns (uint, uint) {
        StakerStatus storage status = _stakerStakes[staker];
        return (status.stakeSum, status.powerSum);
    }

    function getStakerStakesBare(address staker) external view returns (StakerStatus memory) {
        return _stakerStakes[staker];
    }

    function getStakerStakesLength(address staker) external view returns (uint) {
        return _stakerStakes[staker].stakes.length;
    }

    function getStakerStakesSingle(address staker, uint index) external view returns (Stake memory) {
        return _stakerStakes[staker].stakes[index];
    }

    function getStatus() external view returns (FIGStakeInfo memory) {
        return FIGStakeInfo(
            _accumulatedBonus,
            _accumulatedReleasedBonus,
            _accumulatedStake,
            _accumulatedWithdrawn,
            _accumulatedPowerIn,
            _accumulatedPowerOut,
            _totalPower,
            _lastConfirmedPower,
            _lastConfirmedHeight,
            _pendingPowerIn,
            _pendingPowerOut,
            _pendingHeight,
            _nextStakeId);
    }

    function setFactors(uint new_minStake, uint new_maxStakesPerStaker) onlyOwner external {
        _minStake = new_minStake;
        _maxStakesPerStaker = new_maxStakesPerStaker;
    }

    function getFactors() external view returns (uint[2] memory result) {
        result = [_minStake, _maxStakesPerStaker];
    }

    function getContractAddrs() external view returns (address, address) {
        return (address(_tokenFILGovernance), _foundation);
    }

    function setContractAddrs(
        address new_tokenFILGovernance,
        address payable new_foundation
    ) onlyOwner external {
        _tokenFILGovernance = FILGovernance(new_tokenFILGovernance);
        _foundation = new_foundation;
    }

    function resetStakeRates(uint[] memory stakePeriods, uint[] memory rates) onlyOwner public {
        uint length = stakePeriods.length;
        require(length == rates.length, "Not same length");
        StakeRate[] storage stakeRates = _stakeRates.stakeRates;
        while (stakeRates.length != 0) {
            stakeRates.pop();
        }
        for (uint i = 0; i < length; i++) {
            if (i > 0) {
                require(stakePeriods[i] > stakePeriods[i - 1], "Invalid stakePeriods");
            }
            stakeRates.push(StakeRate(stakePeriods[i], rates[i]));
        }
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner allowed");
        _;
    }

    modifier onlyFoundation() {
        require(_msgSender() == _foundation, "Only foundation allowed");
        _;
    }

    function _getStakePos(address staker, uint stakeId) private view returns (uint p) {
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        for (; p < stakes.length; p++) {
            if (stakes[p].stakeId == stakeId) break;
        }
        require(p != stakes.length, "Invalid stakeId");
    }

    function _getLocked(uint initialAmount, uint startHeight, uint totallyReleasedHeight, uint height) private pure returns (uint) {
        if (totallyReleasedHeight <= startHeight || height >= totallyReleasedHeight) return 0;
        else if (height <= startHeight) return initialAmount;
        else return (totallyReleasedHeight - height) * initialAmount / (totallyReleasedHeight - startHeight);
    }

    function _getStakeInfoByPos(address staker, uint pos) private view returns (StakeInfo memory result) {
        Stake storage stake = _stakerStakes[staker].stakes[pos];
        result.stake = stake;
        if (stake.end > 0) {
            result.withdrawStatus = 2;
        } else if (block.number >= stake.start + stake.duration) {
            result.withdrawStatus = 1;
        }
        uint nextBonusIndex = getNextBonusIndex();
        if (nextBonusIndex > 0) {
            result.releasableAmount = _getReleaseBonusAmount(stake, nextBonusIndex - 1);
        }
    }

    function _updateData() private {
        uint current = block.number;
        _totalPower += (_pendingHeight - _lastConfirmedHeight - 1) * _lastConfirmedPower;
        if (_pendingHeight < current) {
            _lastConfirmedPower = _lastConfirmedPower - _pendingPowerOut + _pendingPowerIn;
            _totalPower += (current - _pendingHeight) * _lastConfirmedPower;
            _pendingHeight = current;
            _pendingPowerOut = 0;
            _pendingPowerIn = 0;
        }
        _lastConfirmedHeight = current - 1;
    }

    function _getReleaseBonusAmount(Stake storage stake, uint bonusIndex) private view returns (uint amount) {
        Bonus storage bonus = _bonuses.bonuses[bonusIndex];
        if (bonus.totalAmount == 0 || bonus.totalStakedPower == 0) {
            return 0;
        }
        uint end = stake.end;
        if (end == 0 || end > bonus.height) {
            end = bonus.height;
        }
        uint start = stake.start;
        if (start > bonus.height) {
            start = bonus.height;
        }
        if (bonusIndex > 0) {
            uint bonusStart = _bonuses.bonuses[bonusIndex - 1].height;
            if (bonusStart > start) {
                start = bonusStart;
            }
            if (bonusStart > end) {
                end = bonusStart;
            }
        }
        return (end - start) * _getStakePower(stake.amount, stake.rate) * bonus.totalAmount / bonus.totalStakedPower;
    }

    function _releaseBonus4AllStakes(uint bonusIndex) private returns (uint released) {
        require(bonusIndex < getNextBonusIndex(), "Invalid bonus index");
        address staker = _msgSender();
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        for (uint j = stakes.length; j > 0; j--) {
            Stake storage stake = stakes[j - 1];
            require(_canReleaseBonusAt(stake.nextBonusIndex, bonusIndex), "Cannot release this bonus for the stake");
            uint releasedCurrent = 0;
            for (uint i = stake.nextBonusIndex; i <= bonusIndex; i++) {
                releasedCurrent += _getReleaseBonusAmount(stake, i);
                _bonuses.bonuses[i].releasedAmount += releasedCurrent;
            }
            stake.nextBonusIndex = bonusIndex + 1;
            stake.haveReleased += releasedCurrent;
            released += releasedCurrent;
            emit BonusReleased(staker, stake.stakeId, bonusIndex, stake.amount, releasedCurrent);
            if (stake.haveUnstaked && (stake.nextBonusIndex == getNextBonusIndex() || stake.end <= _bonuses.bonuses[bonusIndex].height)) {
                stakes[j] = stakes[stakes.length - 1];
                stakes.pop();
            }
        }
        if (released > 0) {
            _accumulatedReleasedBonus += released;
            payable(staker).transfer(released);
        }
    }

    function _canReleaseBonusAt(uint nextBonusIndex, uint bonusIndex) public pure returns (bool) {
        return nextBonusIndex < bonusIndex;
    }

    function _getStakePower(uint amount, uint rate) private pure returns (uint) {
        return amount * rate / RATE_BASE;
    }
}
