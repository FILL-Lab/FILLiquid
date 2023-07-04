// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./Utils/Calculation.sol";

contract FILStake is Context{
    struct Stake {
        uint amount;
        uint start;
        uint end;
    }
    struct StakeInfo {
        Stake stake;
        bool canWithdraw;
    }
    struct StakerInfo {
        address staker;
        StakeInfo[] stakes;
    }
    event Interest(
        address mintee,
        uint amount,
        uint minted
    );
    event Staked(
        address staker,
        uint amount,
        uint start,
        uint end,
        uint minted
    );
    event Unstaked(
        address staker,
        uint amount,
        uint start,
        uint end,
        uint realEnd,
        uint minted
    );

    mapping(address => Stake[]) private _stakerStakes;
    address[] private _stakers;
    address private _owner;
    address private _filLiquid;

    uint private _accumulatedInterest;
    uint private _accumulatedStake;
    uint private _accumulatedInterestMint;
    uint private _accumulatedStakeMint;

    uint private _n_interest;
    uint private _n_stake;
    uint private _minStakePeriod;
    uint private _maxStakePeriod;
    uint private _rateBase;
    uint private _interest_share;
    uint private _stake_share;

    FILTrust private _tokenFILTrust;
    Calculation private _calculation;
    FILGovernance private _tokenFILGovernance;

    uint constant DEFAULT_N_INTEREST = 1500000 * 10 ** 18;
    //TODO: make sure of factor value
    uint constant DEFAULT_N_STAKE = 1500000 * 10 ** 18 * DEFAULT_MIN_STAKE_PERIOD;
    uint constant DEFAULT_MIN_STAKE_PERIOD = 259200;//90 days
    uint constant DEFAULT_MAX_STAKE_PERIOD = 1051200;//365 days
    uint constant DEFAULT_RATE_BASE = 1000000;
    uint constant DEFAULT_INTEREST_SHARE = 300000;
    uint constant DEFAULT_STAKE_SHARE = 700000;

    constructor() {
        _owner = _msgSender();
        _n_interest = DEFAULT_N_INTEREST;
        _n_stake = DEFAULT_N_STAKE;
        _minStakePeriod = DEFAULT_MIN_STAKE_PERIOD;
        _maxStakePeriod = DEFAULT_MAX_STAKE_PERIOD;
        _rateBase = DEFAULT_RATE_BASE;
        _interest_share = DEFAULT_INTEREST_SHARE;
        _stake_share = DEFAULT_STAKE_SHARE;
    }

    function handleInterest(address mintee, uint amount) onlyFilLiquid external returns (uint minted) {
        (minted, _accumulatedInterestMint) = _getMintedFromInterest(amount, _accumulatedInterestMint);
        _accumulatedInterest += amount;
        _tokenFILGovernance.mint(mintee, minted);
        emit Interest(mintee, amount, minted);
    }

    function stakeFilTrust(uint amount, uint maxStart, uint duration) external returns (uint minted) {
        require(block.number <= maxStart, "Block height exceeds");
        require(duration >= _minStakePeriod && duration <= _maxStakePeriod, "Duration invalid");
        address sender = _msgSender();
        require(_tokenFILTrust.allowance(sender, address(this)) >= amount, "Allowance not enough");
        _tokenFILTrust.transferFrom(sender, address(this), amount);
        (uint start, uint end) = (block.number, block.number + duration);
        Stake[] storage stakes = _stakerStakes[sender];
        stakes.push(
            Stake({
                amount: amount,
                start: start,
                end: end
            })
        );
        if (stakes.length == 1) _stakers.push(sender);

        minted = _mintedFromStake(sender, amount, duration);
        emit Staked(sender, amount, start, end, minted);
    }

    function unStakeFilTrust(uint stakeId) external returns (uint minted) {
        address sender = _msgSender();
        Stake[] storage stakes = _stakerStakes[sender];
        require(stakes.length > stakeId, "Invalid stakeId");
        Stake storage stake = stakes[stakeId];
        uint realEnd = block.number;
        require(realEnd >= stake.end, "Stake not withdrawable");
        if (realEnd > stake.end) minted = _mintedFromStake(sender, stake.amount, realEnd - stake.end);
        _tokenFILTrust.transfer(sender, stake.amount);
        emit Unstaked(sender, stake.amount, stake.start, stake.end, realEnd, minted);

        if (stakeId != stakes.length - 1) {
            stake = stakes[stakes.length - 1];
        }
        stakes.pop();
        if (stakes.length == 0) {
            delete _stakerStakes[sender];
            for (uint i = 0; i < _stakers.length; i++) {
                if (_stakers[i] == sender) {
                    if (i != _stakers.length - 1) {
                        _stakers[i] = _stakers[_stakers.length - 1];
                    }
                    _stakers.pop();
                    break;
                }
            }
        }
    }

    function getStakers() external view returns (address[] memory) {
        return _stakers;
    }

    function getAllStakes() external view returns (StakerInfo[] memory result) {
        result = new StakerInfo[](_stakers.length);
        for (uint i = 0; i < result.length; i++) {
            result[i] = getStakerStakes(_stakers[i]);
        }
    }

    function getStakerStakes(address staker) public view returns (StakerInfo memory result) {
        result.staker = staker;
        Stake[] storage stakes = _stakerStakes[staker];
        result.stakes = new StakeInfo[](stakes.length);
        for (uint i = 0; i < stakes.length; i++) {
            result.stakes[i].stake = stakes[i];
            result.stakes[i].canWithdraw = block.number >= stakes[i].end;
        }
    }

    function setFactors(uint new_n_interest, uint new_n_stake, uint new_rateBase, uint new_interest_share, uint new_stake_share) onlyOwner external {
        require(new_rateBase == new_interest_share + new_stake_share, "factor invalid");
        _n_interest = new_n_interest;
        _n_stake = new_n_stake;
        _rateBase = new_rateBase;
        _interest_share = new_interest_share;
        _stake_share = new_stake_share;
    }

    function getStatus() external view returns (uint, uint, uint, uint) {
        return (_accumulatedInterest, _accumulatedStake, _accumulatedInterestMint, _accumulatedStakeMint);
    }

    function getFactors() external view returns (uint, uint, uint, uint, uint, uint, uint) {
        return (_n_interest, _n_stake, _minStakePeriod, _maxStakePeriod, _rateBase, _interest_share, _stake_share);
    }

    function setFactors(
        uint new_n_interest,
        uint new_n_stake,
        uint new_minStakePeriod,
        uint new_maxStakePeriod,
        uint new_rateBase,
        uint new_interest_share,
        uint new_stake_share
    ) external {
        _n_interest = new_n_interest;
        _n_stake = new_n_stake;
        _minStakePeriod = new_minStakePeriod;
        _maxStakePeriod = new_maxStakePeriod;
        _rateBase = new_rateBase;
        _interest_share = new_interest_share;
        _stake_share = new_stake_share;
    }

    function getContactAddrs() external view returns (address, address, address, address) {
        return (_filLiquid, address(_tokenFILTrust), address(_calculation), address(_tokenFILGovernance));
    }

    function setContactAddrs(
        address new_filLiquid,
        address new_tokenFILTrust,
        address new_calculation,
        address new_tokenFILGovernance
    ) onlyOwner external {
        _filLiquid = new_filLiquid;
        _tokenFILTrust = FILTrust(new_tokenFILTrust);
        _calculation = Calculation(new_calculation);
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

    modifier onlyFilLiquid() {
        require(_msgSender() == _filLiquid, "Only filLiquid allowed");
        _;
    }

    function _mintedFromStake(address staker, uint stake, uint duration) private returns (uint minted) {
        (minted, _accumulatedStakeMint) = _getMintedFromStake(stake, duration, _accumulatedStakeMint);
        _accumulatedStake += stake;
        _tokenFILGovernance.mint(staker, minted);
    }

    function _getMintedFromInterest(uint interest, uint lastAccumulated) private view returns (uint, uint) {
        return _calculation.getMinted(_accumulatedInterest, interest, _n_interest, _tokenFILGovernance.maxSupply() * _interest_share / _rateBase, lastAccumulated);
    }

    function _getMintedFromStake(uint stake, uint duration, uint lastAccumulated) private view returns (uint, uint) {
        return _calculation.getMinted(_accumulatedStake, stake * duration, _n_stake, _tokenFILGovernance.maxSupply() * _stake_share / _rateBase, lastAccumulated);
    }
}
