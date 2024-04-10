// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./Utils/Calculation.sol";

contract FITStake is Context{
    struct Stake {
        uint id;
        uint amount;
        uint start;
        uint end;
        uint totalFIG;
        uint releasedFIG;
    }
    struct StakerStatus {
        uint stakeSum;
        uint totalFIGSum;
        uint releasedFIGSum;
        Stake[] stakes;
    }
    struct StakeInfo {
        Stake stake;
        bool canWithdrawFIT;
        uint canWithdrawFIG;
    }
    struct StakerInfo {
        address staker;
        uint stakeSum;
        uint totalFIGSum;
        uint releasedFIGSum;
        uint canWithdrawFITSum;
        uint canWithdrawFIGSum;
        StakeInfo[] stakeInfos;
    }
    struct FITStakeInfo {
        uint accumulatedInterest;
        uint accumulatedStake;
        uint accumulatedStakeDuration;
        uint accumulatedInterestMint;
        uint accumulatedStakeMint;
        uint accumulatedWithdrawn;
        uint nextStakeID;
        uint releasedFIGStake;
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
    event WithdrawnFIG(
        address indexed staker,
        uint indexed id,
        uint amount
    );
    event SharesChanged(
        uint new_rateBase,
        uint new_interest_share,
        uint new_stake_share
    );
    event StakeParamsChanged(
        uint new_minStakePeriod,
        uint new_maxStakePeriod,
        uint new_minStake,
        uint new_maxStakes
    );
    event ContractAddrsChanged(
        address new_filLiquid,
        address new_governance,
        address new_tokenFILTrust,
        address new_calculation,
        address new_tokenFILGovernance
    );
    event OwnerChanged(
        address new_owner
    );
    event GovernanceFactorsChanged(
        uint _n_interest,
        uint _n_stake
    );

    mapping(address => StakerStatus) private _stakerStakes;
    mapping(address => bool) private _onceStaked;
    mapping(uint => address) private _idStaker;
    address[] private _stakers;
    address private _owner;
    address private _filLiquid;
    address private _governance;

    uint private _accumulatedInterest;
    uint private _accumulatedStake;
    uint private _accumulatedStakeDuration;
    uint private _accumulatedInterestMint;
    uint private _accumulatedStakeMint;
    uint private _accumulatedWithdrawn;
    uint private _nextStakeID;
    uint private _releasedFIGStake;

    uint private _n_interest;
    uint private _n_stake;
    uint private _minStakePeriod;
    uint private _maxStakePeriod;
    uint private _minStake;
    uint private _maxStakes;
    uint private _rateBase;
    uint private _interest_share;
    uint private _stake_share;

    FILTrust private _tokenFILTrust;
    Calculation private _calculation;
    FILGovernance private _tokenFILGovernance;

    uint constant DEFAULT_N_INTEREST = 1.2e25;
    uint constant DEFAULT_N_STAKE = 1.36449194112e31;
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

    function handleInterest(address minter, uint principal, uint interest) onlyFiLLiquid external returns (uint minted) {
        _accumulatedInterest += interest;
        (minted, _accumulatedInterestMint) = getCurrentMintedFromInterest(interest);
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
        if (!_onceStaked[staker]) {
            _stakers.push(staker);
            _onceStaked[staker] = true;
        }
        minted = _mintedFromStake(address(this), amount, duration);
        status.totalFIGSum += minted;
        stakes.push(
            Stake({
                id: _nextStakeID++,
                amount: amount,
                start: start,
                end: end,
                totalFIG: minted,
                releasedFIG: 0
            })
        );
        emit Staked(staker, _nextStakeID - 1, amount, start, end, minted);
    }

    function unStakeFilTrust(uint stakeId) external returns (uint minted, uint withdrawnFIG) {
        address staker = _msgSender();
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        uint pos = _getStakePos(staker, stakeId);
        Stake storage stake = stakes[pos];
        require(block.number >= stake.end, "Stake not withdrawable");
        uint stakeAmount = stake.amount;
        uint unwithdrawnFIG = stake.totalFIG - stake.releasedFIG;
        StakerStatus storage status = _stakerStakes[staker];
        status.stakeSum -= stakeAmount;
        status.totalFIGSum -= stake.totalFIG;
        status.releasedFIGSum -= stake.releasedFIG;
        _accumulatedWithdrawn += stakeAmount;
        if (block.number > stake.end) minted = _mintedFromStake(staker, stakeAmount, block.number - stake.end);
        emit Unstaked(staker, stakeId, stakeAmount, stake.start, stake.end, block.number, minted);
        stakes[pos] = stakes[stakes.length - 1];
        stakes.pop();
        if (unwithdrawnFIG > 0) {
            _releasedFIGStake += unwithdrawnFIG;
            withdrawnFIG = unwithdrawnFIG;
            emit WithdrawnFIG(staker, stakeId, unwithdrawnFIG);
            _tokenFILGovernance.transfer(staker, unwithdrawnFIG);
        }
        _tokenFILTrust.transfer(staker, stakeAmount);
    }

    function withdrawFIG(uint stakeId) external returns (uint withdrawn) {
        address staker = _msgSender();
        uint pos = _getStakePos(staker, stakeId);
        StakerStatus storage status = _stakerStakes[staker];
        Stake storage stake = status.stakes[pos];
        withdrawn = _canWithdrawFIG(stake);
        if (withdrawn > 0) {
            status.releasedFIGSum += withdrawn;
            stake.releasedFIG += withdrawn;
            _releasedFIGStake += withdrawn;
            emit WithdrawnFIG(staker, stake.id, withdrawn);
            _tokenFILGovernance.transfer(staker, withdrawn);
        }
    }

    function canWithDrawFIG(uint stakeId) external view returns(uint canWithdraw) {
        address staker = _idStaker[stakeId];
        uint pos = _getStakePos(staker, stakeId);
        Stake storage stake = _stakerStakes[staker].stakes[pos];
        canWithdraw = _canWithdrawFIG(stake);
    }

    function withdrawFIGAll() external returns (uint withdrawn) {
        address staker = _msgSender();
        StakerStatus storage status = _stakerStakes[staker];
        Stake[] storage stakes = status.stakes;
        for (uint pos = 0; pos < stakes.length; pos++) {
            Stake storage stake = _stakerStakes[staker].stakes[pos];
            uint canWithdraw = _canWithdrawFIG(stake);
            if (canWithdraw > 0) {
                stake.releasedFIG += canWithdraw;
                withdrawn += canWithdraw;
                emit WithdrawnFIG(staker, stake.id, canWithdraw);
            }
        }
        if (withdrawn > 0) {
            status.releasedFIGSum += withdrawn;
            _releasedFIGStake += withdrawn;
            _tokenFILGovernance.transfer(staker, withdrawn);
        }
    }

    function canWithdrawFIGAll(address staker) external view returns (uint withdrawn) {
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        for (uint pos = 0; pos < stakes.length; pos++) {
            Stake storage stake = _stakerStakes[staker].stakes[pos];
            withdrawn += _canWithdrawFIG(stake);
        }
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
        result.totalFIGSum = status.totalFIGSum;
        result.releasedFIGSum = status.releasedFIGSum;
        result.stakeInfos = new StakeInfo[](stakes.length);
        uint height = block.number;
        for (uint i = 0; i < stakes.length; i++) {
            result.stakeInfos[i].stake = stakes[i];
            bool canWithdrawFIT = height >= stakes[i].end;
            if (canWithdrawFIT) {
                result.stakeInfos[i].canWithdrawFIT = true;
                result.canWithdrawFITSum += stakes[i].amount;
            }
            uint canWithdrawFIG = _canWithdrawFIG(stakes[i]);
            if (canWithdrawFIG > 0) {
                result.stakeInfos[i].canWithdrawFIG = canWithdrawFIG;
                result.canWithdrawFIGSum += canWithdrawFIG;
            }
        }
    }

    function getStakerTerms(address staker) external view returns (uint stakeSum, uint totalFIGSum, uint releasedFIGSum, uint canWithdrawFITSum, uint canWithdrawFIGSum) {
        StakerStatus storage status = _stakerStakes[staker];
        Stake[] storage stakes = status.stakes;
        stakeSum = status.stakeSum;
        totalFIGSum = status.totalFIGSum;
        releasedFIGSum = status.releasedFIGSum;
        uint height = block.number;
        for (uint i = 0; i < stakes.length; i++) {
            if (height >= stakes[i].end) {
                canWithdrawFITSum += stakes[i].amount;
            }
            canWithdrawFIGSum += _canWithdrawFIG(stakes[i]);
        }
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
        result.canWithdrawFIT = block.number >= stakes[pos].end;
        result.canWithdrawFIG = _canWithdrawFIG(stakes[pos]);
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

    function getStatus() external view returns (FITStakeInfo memory) {
        return FITStakeInfo(_accumulatedInterest, _accumulatedStake, _accumulatedStakeDuration, _accumulatedInterestMint, _accumulatedStakeMint, _accumulatedWithdrawn, _nextStakeID,  _releasedFIGStake);
    }

    function setShares(uint new_rateBase, uint new_interest_share, uint new_stake_share) onlyOwner external {
        require(new_rateBase != 0 && new_interest_share != 0 && new_stake_share != 0 && new_rateBase == new_interest_share + new_stake_share, "factor invalid");
        _rateBase = new_rateBase;
        _interest_share = new_interest_share;
        _stake_share = new_stake_share;
        emit SharesChanged(new_rateBase, new_interest_share, new_stake_share);
    }

    function setStakeParams(uint new_minStakePeriod, uint new_maxStakePeriod, uint new_minStake, uint new_maxStakes) onlyOwner external {
        require(new_minStakePeriod <= new_maxStakePeriod && new_minStake <= new_maxStakes, "Invalid params");
        _minStakePeriod = new_minStakePeriod;
        _maxStakePeriod = new_maxStakePeriod;
        _minStake = new_minStake;
        _maxStakes = new_maxStakes;
        emit StakeParamsChanged(new_minStakePeriod, new_maxStakePeriod, new_minStake, new_maxStakes);
    }

    function setGovernanceFactors(uint[] calldata params) onlyGovernance external {
        _n_interest = params[0];
        _n_stake = params[1];
        emit GovernanceFactorsChanged(params[0], params[1]);
    }

    function checkGovernanceFactors(uint[] calldata params) external pure {
        require(params.length == 2, "Invalid input length");
    }

    function getAllFactors() external view returns (uint[9] memory result) {
        result = [_n_interest, _n_stake, _minStakePeriod, _maxStakePeriod, _minStake, _maxStakes, _rateBase, _interest_share, _stake_share];
    }

    function getContractAddrs() external view returns (address, address, address, address, address) {
        return (_filLiquid, _governance, address(_tokenFILTrust), address(_calculation), address(_tokenFILGovernance));
    }

    function setContractAddrs(
        address new_filLiquid,
        address new_governance,
        address new_tokenFILTrust,
        address new_calculation,
        address new_tokenFILGovernance
    ) onlyOwner external {
        _filLiquid = new_filLiquid;
        _governance = new_governance;
        _tokenFILTrust = FILTrust(new_tokenFILTrust);
        _calculation = Calculation(new_calculation);
        _tokenFILGovernance = FILGovernance(new_tokenFILGovernance);
        emit ContractAddrsChanged (new_filLiquid, new_governance, new_tokenFILTrust, new_calculation, new_tokenFILGovernance);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
        emit OwnerChanged(new_owner);
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner allowed");
        _;
    }

    modifier onlyGovernance() {
        require(_msgSender() == _governance, "Only governance allowed");
        _;
    }

    modifier onlyFiLLiquid() {
        require(_msgSender() == _filLiquid, "Only filLiquid allowed");
        _;
    }

    function _getStakePos(address staker, uint stakeId) private view returns (uint p) {
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        for (; p < stakes.length; p++) {
            if (stakes[p].id == stakeId) break;
        }
        require(p != stakes.length, "Invalid stakeId");
    }

    function _mintedFromStake(address staker, uint stake, uint duration) private returns (uint minted) {
        _accumulatedStake += stake;
        _accumulatedStakeDuration += stake * duration;
        (minted, _accumulatedStakeMint) = getCurrentMintedFromStake(stake, duration);
        if (minted > 0) _tokenFILGovernance.mint(staker, minted);
    }

    function _getMintedFromInterest(uint interest, uint lastAccumulated) private view returns (uint, uint) {
        return _calculation.getMinted(_accumulatedInterest, interest, _n_interest, _tokenFILGovernance.maxLiquid() * _interest_share / _rateBase, lastAccumulated);
    }

    function _getMintedFromStake(uint stakeDuration, uint lastAccumulated) private view returns (uint, uint) {
        return _calculation.getMinted(_accumulatedStakeDuration, stakeDuration, _n_stake, _tokenFILGovernance.maxLiquid() * _stake_share / _rateBase, lastAccumulated);
    }

    function _getLocked(uint initialAmount, uint startHeight, uint totallyReleasedHeight, uint height) private pure returns (uint) {
        if (totallyReleasedHeight <= startHeight || height >= totallyReleasedHeight) return 0;
        else if (height <= startHeight) return initialAmount;
        else return (totallyReleasedHeight - height) * initialAmount / (totallyReleasedHeight - startHeight);
    }

    function _canWithdrawFIG(Stake storage stake) private view returns (uint) {
        return stake.totalFIG - _getLocked(stake.totalFIG, stake.start, stake.end, block.number) - stake.releasedFIG;
    }
}
