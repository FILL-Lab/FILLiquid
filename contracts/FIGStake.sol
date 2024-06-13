// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


import "./FILGovernance.sol";

contract FIGStake is Ownable {
    event EventBonus(uint index);
    event EventStake(uint id);
    event EventUnstake(uint id);
    event EventWithdraw(uint bonusIndex, uint stakeId, address to, uint amount);
    event EventChangePeriod(Period[] periods);
    
    uint constant RATE_BASE = 1000000;

    struct Stake {
        address staker;
        uint amount;
        uint weight;
        uint startBonusIndex;
        uint stakeTimestamp;
        uint unlockTimestamp;
        bool unstaked;
        uint unstakeTimestamp;
        uint bonusNumber;
        uint withdrawNumber;
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

    Bonus[] public _bonuses;
    Period[] public _periods;
    Period[] public _nextPeriods;

    uint public _accumulatedStakeAmountWeight;
    uint public _accumulatedStakeAmountWeightTimestamp;

    uint public _accumulatedUnstakeAmountWeight;
    uint public _accumulatedUnstakeAmountWeightTimestamp;

    uint public _lastBonusAccumulatedTotalPower;
    uint public _nextBoundTimestamp;
    uint public _accumulatedStakeNumber;

    mapping(uint => mapping(uint => bool)) public _stakeBonuswithdrawn;

    mapping(uint => Stake) public _stakes;

    function addBonus(uint amount, uint startTimestamp) payable external onlyOwner() {
        require(amount == msg.value, "amount incorrect");
        require(_nextBoundTimestamp == startTimestamp, "startTimestamp incorrect");
        _periods = _nextPeriods;

        uint totalPower = _accumulatedStakeAmountWeight * block.timestamp - _accumulatedStakeAmountWeightTimestamp - (_accumulatedUnstakeAmountWeight * block.timestamp - _accumulatedUnstakeAmountWeightTimestamp) - _lastBonusAccumulatedTotalPower;

        _lastBonusAccumulatedTotalPower += totalPower;
        _bonuses.push(Bonus(msg.value, block.timestamp, totalPower));
    }

    receive() onlyOwner external payable {
        // _periods = _nextPeriods;

        // console.log("_accumulatedStakeAmountWeight: ", _accumulatedStakeAmountWeight);
        // console.log("block.timestamp: ", block.timestamp);
        // console.log("_accumulatedStakeAmountWeightTimestamp: ", _accumulatedStakeAmountWeightTimestamp);
        // console.log("_accumulatedUnstakeAmountWeight: ", _accumulatedUnstakeAmountWeight);
        // console.log("_accumulatedUnstakeAmountWeightTimestamp: ", _accumulatedUnstakeAmountWeightTimestamp);
        // console.log("_lastBonusAccumulatedTotalPower: ", _lastBonusAccumulatedTotalPower);

        // uint totalPower = _accumulatedStakeAmountWeight * block.timestamp - _accumulatedStakeAmountWeightTimestamp - (_accumulatedUnstakeAmountWeight * block.timestamp - _accumulatedUnstakeAmountWeightTimestamp) - _lastBonusAccumulatedTotalPower;

        // _lastBonusAccumulatedTotalPower += totalPower;
        // _bonuses.push(Bonus(msg.value, block.timestamp, totalPower));
    }

    constructor(address tokenFILGovernance, address foundation, Period[] memory periods) Ownable(foundation) {
        _tokenFILGovernance = FILGovernance(tokenFILGovernance);
        _setPeriods(periods);
        _setNextPeriods(periods);
    }

    function stake(uint amount, uint maxStart, uint periodIndex) external {
        Period storage period = _periods[periodIndex];
        uint stakeAmountWeight = period.weight * amount;
        _accumulatedStakeAmountWeight += stakeAmountWeight;
        _accumulatedStakeAmountWeightTimestamp += stakeAmountWeight * block.timestamp;

        _stakes[_accumulatedStakeNumber] = Stake({
            staker: msg.sender,
            amount: amount,
            weight: period.weight,
            startBonusIndex: _bonuses.length,
            stakeTimestamp: block.timestamp,
            unlockTimestamp: block.timestamp + period.duration,
            unstaked: false,
            unstakeTimestamp: 0,
            bonusNumber: 0,
            withdrawNumber: 0
        });
        emit EventStake(_accumulatedStakeNumber);
        _accumulatedStakeNumber += 1;
    }

    function unstake(uint64 id) external {
        Stake storage stake = _stakes[id];
        require(stake.unlockTimestamp <= block.timestamp, "not yet due");
        _accumulatedUnstakeAmountWeight += stake.weight * stake.amount;
        _accumulatedUnstakeAmountWeightTimestamp += _accumulatedUnstakeAmountWeight * block.timestamp;
        stake.unstaked = true;
        stake.unstakeTimestamp = block.timestamp;
        stake.bonusNumber = _bonuses.length + 1 - stake.startBonusIndex;
        emit EventUnstake(id);
    }

    function withdrawByBonusIndicesStakeIds(uint[] calldata bonusIndices, uint[] calldata stakeIds, address to) external {
        uint totalAmount = 0;
        for (uint i=0; i < stakeIds.length; i++) {
            uint stakeId = stakeIds[i];
            Stake storage stake = _stakes[stakeId];
            require(_stakes[stakeId].staker == msg.sender, "not staker");
            for (uint j=0; j < bonusIndices.length; j++) {
                uint bonusIndex = bonusIndices[j];
                require(_stakeBonuswithdrawn[bonusIndex][stakeId] == false, "Already withdrawn");
                uint amount = _getBonusByBonusIndexStakeId(stakeId, bonusIndex);
                totalAmount += amount;
                _stakeBonuswithdrawn[stakeId][bonusIndex] = true;
                stake.withdrawNumber += 1;
                if (stake.unstaked && stake.bonusNumber == stake.withdrawNumber) {
                    delete _stakes[stakeId];
                }
                emit EventWithdraw(bonusIndex, stakeId, msg.sender, amount);
            }
        }
        payable(msg.sender).transfer(totalAmount);
    }

    function setNextBounsTimestamp(uint nextBoundTimestamp) external onlyOwner {
        _nextBoundTimestamp = nextBoundTimestamp;
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

    function getBonusByBonusIndicesStakeIds(uint[] calldata bonusIndices, uint[] calldata stakeIds) external view returns (uint){
        uint totalAmount = 0;
        for (uint i=0; i < bonusIndices.length; i++) {
            uint bonusIndex = bonusIndices[i];
            for (uint j=0; j < stakeIds.length; j++) {
                uint stakeId = stakeIds[j];
                totalAmount += _getBonusByBonusIndexStakeId(bonusIndex, stakeId);
            }
        }
        return totalAmount;
    }
    function getBonusByBonusIndexStakeId(uint bonusIndex, uint stakeId) external view returns (uint) {
        return _getBonusByBonusIndexStakeId(bonusIndex, stakeId);
    }

    function _getBonusByBonusIndexStakeId(uint bonusIndex, uint stakeId) private view returns (uint) {
        Bonus storage bonus = _bonuses[bonusIndex];
        Stake storage stake = _stakes[stakeId];

        uint startTimestamp = stake.stakeTimestamp;
        if (bonusIndex > 0) {
            startTimestamp = _bonuses[bonusIndex - 1].timestamp;
        }
        uint endTimestamp = stake.unstakeTimestamp;
        if (stake.unstaked == false) {
            endTimestamp = 2**256-1;
        }
        if (endTimestamp > bonus.timestamp) {
            endTimestamp = bonus.timestamp;
        }
        if (startTimestamp >= endTimestamp) {
            return 0;
        }
        uint power = stake.amount * (endTimestamp - startTimestamp) * stake.weight;
        uint amount = power * RATE_BASE / bonus.totalPower * bonus.amount / RATE_BASE;

        console.log("endTimestamp: ", endTimestamp);
        console.log("startTimestamp: ", startTimestamp);
        console.log("power: ", power);
        console.log("stake.weight: ", stake.weight);
        console.log("stake.amount: ", stake.amount);
        console.log("endTimestamp - startTimestamp: ", endTimestamp - startTimestamp);

        return amount;
    }

    function getStakeById(uint id) external view returns (Stake memory){
        return _stakes[id];
    }

    function getPeriodByIndex(uint index) external view returns (Period memory){
        return _periods[index];
    }

    function getBonusByIndex(uint index) external view returns (Bonus memory){
        return _bonuses[index];
    }

    function getAccumulatedStakeNumber() external view returns (uint) {
        return _accumulatedStakeNumber;
    }

    function getPeroidsLength(uint index) external view returns (uint) {
        return _periods.length;
    }

    function getBonusesLength(uint index) external view returns (uint) {
        return _bonuses.length;
    }

    function getNextBoundTimestamp(uint index) external view returns (uint) {
        return _nextBoundTimestamp;
    }
}