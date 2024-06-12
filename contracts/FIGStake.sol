// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


import "./FILGovernance.sol";

contract FIGStake is Ownable {
    
    uint constant RATE_BASE = 1000000;

    struct Stake {
        address staker;
        uint amount;
        uint weight;
        uint startTimestamp;
        uint endTimestamp;
        bool unstaked;
    }

    struct Bonus {
        uint amount;
        uint timestamp;
        uint totalPower;
    }

    struct Period {
        uint weight;
        uint duration;
    }

    FILGovernance private _tokenFILGovernance;

    Stake[] public _stakes;
    Bonus[] public _bonuses;
    Period[] public _periods;

    Period[] public _nextPeriods;

    uint public _accumulatedStakeAmountWeight;
    uint public _accumulatedStakeAmountWeightTimestamp;

    uint public _accumulatedUnstakeAmountWeight;
    uint public _accumulatedUnstakeAmountWeightTimestamp;

    uint public _initAccumulatedTimestamp;

    uint public _lastBonusAccumulatedTotalPower = 0;

    mapping(uint => mapping(uint => bool)) public _stakeBonuswithdrawn;
    mapping(address => uint[]) public _userStakes;

    // address public _foundation;

    // modifier onlyFoundation() {
    //     require(_msgSender() == _foundation, "Only foundation allowed");
    //     _;
    // }

    receive() onlyOwner external payable {
        _periods = _nextPeriods;

        console.log("_accumulatedStakeAmountWeight: ", _accumulatedStakeAmountWeight);
        console.log("block.timestamp: ", block.timestamp);
        console.log("_accumulatedStakeAmountWeightTimestamp: ", _accumulatedStakeAmountWeightTimestamp);
        console.log("_accumulatedUnstakeAmountWeight: ", _accumulatedUnstakeAmountWeight);
        console.log("_accumulatedUnstakeAmountWeightTimestamp: ", _accumulatedUnstakeAmountWeightTimestamp);
        console.log("_lastBonusAccumulatedTotalPower: ", _lastBonusAccumulatedTotalPower);

        uint totalPower = _accumulatedStakeAmountWeight * block.timestamp - _accumulatedStakeAmountWeightTimestamp - (_accumulatedUnstakeAmountWeight * block.timestamp - _accumulatedUnstakeAmountWeightTimestamp) - _lastBonusAccumulatedTotalPower;

        // uint totalPower = _accumulatedStakeAmountWeight * block.timestamp + _accumulatedUnstakeAmountWeightTimestamp - (_accumulatedUnstakeAmountWeight * block.timestamp) - _lastBonusAccumulatedTotalPower;

        _lastBonusAccumulatedTotalPower += totalPower;
        _bonuses.push(Bonus(msg.value, block.timestamp, totalPower));
    }

    constructor(address tokenFILGovernance, address foundation, Period[] memory periods) Ownable(foundation) {
        _tokenFILGovernance = FILGovernance(tokenFILGovernance);
        // _periods = periods;
        _setPeriods(periods);
        _setNextPeriods(periods);
        // _foundation = foundation;
    }

    function stake(uint amount, uint maxStart, uint periodIndex) external{
        Period storage period = _periods[periodIndex];
        uint stakeAmountWeight = period.weight * amount;
        _accumulatedStakeAmountWeight += stakeAmountWeight;
        _accumulatedStakeAmountWeightTimestamp += stakeAmountWeight * block.timestamp;
        _stakes.push(Stake(msg.sender, amount, period.weight, block.timestamp, block.timestamp+period.duration, false));
    }

    function unstake(uint64 index) external {
        Stake storage stake = _stakes[index];
        _accumulatedUnstakeAmountWeight += stake.weight * stake.amount;
        _accumulatedUnstakeAmountWeightTimestamp += _accumulatedUnstakeAmountWeight * block.timestamp;
        stake.unstaked = true;
    }

    function withdrawByBonusIndicesStakeIndices(uint[] calldata bonusIndices, uint[] calldata stakeIndices, address to) external {
        uint totalAmount = 0;
        for (uint i=0; i < bonusIndices.length; i++) {
            uint bonusIndex = bonusIndices[i];
            for (uint j=0; j < bonusIndices.length; j++) {
                uint stakeIndex = bonusIndices[j];
                require(_stakeBonuswithdrawn[bonusIndex][stakeIndex] == false, "Already withdrawn");
                totalAmount += _getBonusByBonusIndexStakeIndex(stakeIndex, bonusIndex);
                _stakeBonuswithdrawn[stakeIndex][bonusIndex] = true;
            }
        }
    }

    function getBonusByBonusIndicesStakeIndices(uint[] calldata BonusIndices, uint[] calldata stakeIndices) external view returns (uint){
        uint totalAmount = 0;
        for (uint i=0; i < BonusIndices.length; i++) {
            uint bonusIndex = BonusIndices[i];
            for (uint j=0; j < BonusIndices.length; j++) {
                uint stakeIndex = BonusIndices[j];
                totalAmount += _getBonusByBonusIndexStakeIndex(bonusIndex, stakeIndex);
            }
        }
        return totalAmount;
    }
    function getBonusByBonusIndexStakeIndex(uint bonusIndex, uint stakeIndex) external view returns (uint) {
        return _getBonusByBonusIndexStakeIndex(bonusIndex, stakeIndex);
    }

    function _getBonusByBonusIndexStakeIndex(uint bonusIndex, uint stakeIndex) private view returns (uint) {
        Bonus storage bonus = _bonuses[bonusIndex];
        Stake storage stake = _stakes[stakeIndex];

        uint startTimestamp = stake.startTimestamp;
        if (bonusIndex > 0) {
            startTimestamp = _bonuses[bonusIndex - 1].timestamp;
        }
        uint endTimestamp = stake.endTimestamp;
        if (endTimestamp > bonus.timestamp) {
            endTimestamp = bonus.timestamp;
        }
        uint power = stake.amount * (endTimestamp - startTimestamp) * stake.weight;
        uint amount = power * RATE_BASE / bonus.totalPower * bonus.amount / RATE_BASE;

        console.log("endTimestamp: ", endTimestamp);
        console.log("startTimestamp: ", startTimestamp);
        console.log("power: ", power);

        return amount;
    }

    function _setPeriods(Period[] memory periods) private {
        uint length = _periods.length;
        for (uint i=0; i<length; i++) {
            _periods.pop();
        }
        for (uint i = 0; i < periods.length; i++) {
            _periods.push(periods[i]);
        }
    }

    function _setNextPeriods(Period[] memory periods) private {
        uint length = _nextPeriods.length;
        for (uint i=0; i<length; i++) {
            _nextPeriods.pop();
        }
        for (uint i = 0; i < periods.length; i++) {
            _nextPeriods.push(periods[i]);
        }
    }

    function setPeriods(Period[] memory periods) external onlyOwner {
        _setNextPeriods(periods);
    }

    function getStakeByIndex(uint index) external view returns (Stake memory){
        return _stakes[index];
    }

    function getPeriodByIndex(uint index) external view returns (Period memory){
        return _periods[index];
    }

    function getBonusByIndex(uint index) external view returns (Bonus memory){
        return _bonuses[index];
    }

    function getStakesLength() external view returns (uint) {
        return _stakes.length;
    }

    function getPeroidsLength(uint index) external view returns (uint) {
        return _periods.length;
    }

    function getBonusesLength(uint index) external view returns (uint) {
        return _bonuses.length;
    }
}