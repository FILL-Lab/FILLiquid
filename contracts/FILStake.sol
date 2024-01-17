// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./Utils/Calculation.sol";

contract FILStake is Context{
    struct Stake {
        uint id;
        uint amount;
        uint start;
        uint end;
    }
    struct StakerStatus {
        uint stakeSum;
        Stake[] stakes;
    }
    struct StakeInfo {
        Stake stake;
        bool canWithdraw;
    }
    struct StakerInfo {
        address staker;
        uint stakeSum;
        StakeInfo[] stakeInfos;
    }
    struct FILStakeInfo {
        uint accumulatedInterest;
        uint accumulatedStake;
        uint accumulatedStakeDuration;
        uint accumulatedInterestMint;
        uint accumulatedStakeMint;
        uint accumulatedWithdrawn;
        uint nextStakeID;
    }
    event Interest(
        address indexed minter,
        uint principal,
        uint interest,
        uint minted
    );
    event Staked(
        address indexed staker,
        uint indexed id,
        uint amount,
        uint start,
        uint end,
        uint minted
    );
    event Unstaked(
        address indexed staker,
        uint indexed id,
        uint amount,
        uint start,
        uint end,
        uint realEnd,
        uint minted
    );

    mapping(address => StakerStatus) private _stakerStakes;
    mapping(address => bool) private _onceStaked;
    mapping(uint => address) private _idStaker;
    address[] private _stakers;
    address private _owner;
    address private _filLiquidLogicBorrowPayback;
    address private _governance;

    uint private _accumulatedInterest;
    uint private _accumulatedStake;
    uint private _accumulatedStakeDuration;
    uint private _accumulatedInterestMint;
    uint private _accumulatedStakeMint;
    uint private _accumulatedWithdrawn;

    uint private _n_interest;
    uint private _n_stake;
    uint private _minStakePeriod;
    uint private _maxStakePeriod;
    uint private _minStake;
    uint private _maxStakes;
    uint private _rateBase;
    uint private _interest_share;
    uint private _stake_share;
    uint private _nextStakeID;

    FILTrust private _tokenFILTrust;
    FILGovernance private _tokenFILGovernance;

    uint constant DEFAULT_N_INTEREST = 9e23;
    uint constant DEFAULT_N_STAKE = 5.7024e30;
    uint constant DEFAULT_MIN_STAKE_PERIOD = 86400; //30 days
    uint constant DEFAULT_MAX_STAKE_PERIOD = 1036800; //360 days
    uint constant DEFAULT_MIN_STAKE = 1 ether;
    uint constant DEFAULT_MAX_STAKES = 100;
    uint constant DEFAULT_RATE_BASE = 10;
    uint constant DEFAULT_INTEREST_SHARE = 4;
    uint constant DEFAULT_STAKE_SHARE = 6;

    constructor() {
        _owner = _msgSender();
        _n_interest = DEFAULT_N_INTEREST;
        _n_stake = DEFAULT_N_STAKE;
        _minStakePeriod = DEFAULT_MIN_STAKE_PERIOD;
        _maxStakePeriod = DEFAULT_MAX_STAKE_PERIOD;
        _minStake = DEFAULT_MIN_STAKE;
        _maxStakes = DEFAULT_MAX_STAKES;
        _rateBase = DEFAULT_RATE_BASE;
        _interest_share = DEFAULT_INTEREST_SHARE;
        _stake_share = DEFAULT_STAKE_SHARE;
    }

    function handleInterest(address minter, uint principal, uint interest) onlyFiLLiquidLogicBorrowPayback external returns (uint minted) {
        (minted, _accumulatedInterestMint) = getCurrentMintedFromInterest(interest);
        _accumulatedInterest += interest;
        if (minted > 0) _tokenFILGovernance.mint(minter, minted);
        emit Interest(minter, principal, interest, minted);
    }

    function stakeFilTrust(uint amount, uint maxStart, uint duration) external returns (uint minted) {
        require(amount >= _minStake, "Amount too small");
        require(maxStart == 0 || block.number <= maxStart, "Block height exceeds");
        require(duration >= _minStakePeriod && duration <= _maxStakePeriod, "Invalid duration");
        address staker = _msgSender();
        _tokenFILTrust.withdraw(staker, amount);
        (uint start, uint end) = (block.number, block.number + duration);
        StakerStatus storage status = _stakerStakes[staker];
        Stake[] storage stakes = status.stakes;
        require(stakes.length < _maxStakes, "Exceed max stakes");
        status.stakeSum += amount;
        _idStaker[_nextStakeID] = staker;
        stakes.push(
            Stake({
                id: _nextStakeID++,
                amount: amount,
                start: start,
                end: end
            })
        );
        if (!_onceStaked[staker]) _stakers.push(staker);
        _onceStaked[staker] = true;
        minted = _mintedFromStake(staker, amount, duration);
        emit Staked(staker, _nextStakeID - 1, amount, start, end, minted);
    }

    function unStakeFilTrust(uint stakeId) external returns (uint minted) {
        address staker = _msgSender();
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        uint pos = _getStakePos(staker, stakeId);
        Stake storage stake = stakes[pos];
        uint realEnd = block.number;
        require(realEnd >= stake.end, "Stake not withdrawable");
        if (realEnd > stake.end) minted = _mintedFromStake(staker, stake.amount, realEnd - stake.end);
        _stakerStakes[staker].stakeSum -= stake.amount;
        _tokenFILTrust.transfer(staker, stake.amount);
        _accumulatedWithdrawn += stake.amount;
        emit Unstaked(staker, stake.id, stake.amount, stake.start, stake.end, realEnd, minted);
        stakes[pos] = stakes[stakes.length - 1];
        stakes.pop();
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
        uint height = block.number;
        for (uint i = 0; i < stakes.length; i++) {
            result.stakeInfos[i].stake = stakes[i];
            result.stakeInfos[i].canWithdraw = height >= stakes[i].end;
        }
    }

    function getStakerTerms(address staker) public view returns (uint fitFixed, uint fitVariable) {
        StakerStatus storage status = _stakerStakes[staker];
        Stake[] storage stakes = status.stakes;
        uint height = block.number;
        for (uint i = 0; i < stakes.length; i++) {
            if (height >= stakes[i].end) fitVariable += stakes[i].amount;
        }
        fitFixed = status.stakeSum - fitVariable;
    }

    /*function getStakeInfoByPos(address staker, uint pos) external view returns (StakeInfo memory result) {
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        require(pos < stakes.length, "Invalid pos");
        result.stake = stakes[pos];
        result.canWithdraw = block.number >= stakes[pos].end;
    }*/

    function getStakerById(uint stakeId) external view returns (address) {
        return _idStaker[stakeId];
    }

    function getStakeInfoById(uint stakeId) external view returns (StakeInfo memory) {
        return getStakeInfoByStakerAndId(_idStaker[stakeId], stakeId);
    }

    function getStakeInfoByStakerAndId(address staker, uint stakeId) public view returns (StakeInfo memory result) {
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        uint pos = _getStakePos(staker, stakeId);
        result.stake = stakes[pos];
        result.canWithdraw = block.number >= stakes[pos].end;
    }

    function getStakerSum(address staker) external view returns (uint) {
        return _stakerStakes[staker].stakeSum;
    }

    function getCurrentMintedFromInterest(uint amount) public view returns (uint, uint) {
        return _getMintedFromInterest(amount, _accumulatedInterestMint);
    }

    function getCurrentMintedFromStake(uint stake, uint duration) public view returns (uint, uint) {
        return _getMintedFromStake(stake * duration, _accumulatedStakeMint);
    }

    function getStatus() external view returns (FILStakeInfo memory) {
        return FILStakeInfo(_accumulatedInterest, _accumulatedStake, _accumulatedStakeDuration, _accumulatedInterestMint, _accumulatedStakeMint, _accumulatedWithdrawn, _nextStakeID);
    }

    function setShares(uint new_rateBase, uint new_interest_share, uint new_stake_share) onlyOwner external {
        require(new_rateBase == new_interest_share + new_stake_share, "factor invalid");
        _rateBase = new_rateBase;
        _interest_share = new_interest_share;
        _stake_share = new_stake_share;
    }

    function setStakeParams(uint new_minStakePeriod, uint new_maxStakePeriod, uint new_minStake, uint new_maxStakes) onlyOwner external {
        _minStakePeriod = new_minStakePeriod;
        _maxStakePeriod = new_maxStakePeriod;
        _minStake = new_minStake;
        _maxStakes = new_maxStakes;
    }

    function setGovernanceFactors(uint[] calldata params) onlyGovernance external {
        _n_interest = params[0];
        _n_stake = params[1];
    }

    function checkGovernanceFactors(uint[] calldata params) external pure {
        require(params.length == 2, "Invalid input length");
    }

    function getAllFactors() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        return (_n_interest, _n_stake, _minStakePeriod, _maxStakePeriod, _minStake, _maxStakes, _rateBase, _interest_share, _stake_share);
    }

    function getContractAddrs() external view returns (address, address, address, address) {
        return (_filLiquidLogicBorrowPayback, _governance, address(_tokenFILTrust), address(_tokenFILGovernance));
    }

    function setContractAddrs(
        address new_filLiquidLogicBorrowPayback,
        address new_governance,
        address new_tokenFILTrust,
        address new_tokenFILGovernance
    ) onlyOwner external {
        _filLiquidLogicBorrowPayback = new_filLiquidLogicBorrowPayback;
        _governance = new_governance;
        _tokenFILTrust = FILTrust(new_tokenFILTrust);
        _tokenFILGovernance = FILGovernance(new_tokenFILGovernance);
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

    modifier onlyGovernance() {
        require(_msgSender() == _governance, "Only governance allowed");
        _;
    }

    modifier onlyFiLLiquidLogicBorrowPayback() {
        require(_msgSender() == _filLiquidLogicBorrowPayback, "Only filLiquidLogicBorrowPayback allowed");
        _;
    }

    function _getStakePos(address staker, uint stakeId) public view returns (uint p) {
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        for (; p < stakes.length; p++) {
            if (stakes[p].id == stakeId) break;
        }
        require(p != stakes.length, "Invalid stakeId");
    }

    function _mintedFromStake(address staker, uint stake, uint duration) private returns (uint minted) {
        (minted, _accumulatedStakeMint) = getCurrentMintedFromStake(stake, duration);
        _accumulatedStake += stake;
        _accumulatedStakeDuration += stake * duration;
        if (minted > 0) _tokenFILGovernance.mint(staker, minted);
    }

    function _getMintedFromInterest(uint interest, uint lastAccumulated) private view returns (uint, uint) {
        return Calculation.getMinted(_accumulatedInterest, interest, _n_interest, _tokenFILGovernance.maxLiquid() * _interest_share / _rateBase, lastAccumulated);
    }

    function _getMintedFromStake(uint stakeDuration, uint lastAccumulated) private view returns (uint, uint) {
        return Calculation.getMinted(_accumulatedStakeDuration, stakeDuration, _n_stake, _tokenFILGovernance.maxLiquid() * _stake_share / _rateBase, lastAccumulated);
    }
}
