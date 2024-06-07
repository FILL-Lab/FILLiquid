// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


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

    uint public _accumulatedStakeAmountWeight;
    uint public _accumulatedStakeAmountWeightTimestamp;

    uint public _accumulatedUnstakeAmountWeight;
    uint public _accumulatedUnstakeAmountWeightTimestamp;

    uint public _initAccumulatedTimestamp;

    uint public _accumulatedTotalPower;

    mapping(uint => mapping(uint => bool)) public _stakeBonuswithdrawn;
    mapping(address => uint[]) public _userStakes;

    // address public _foundation;

    // modifier onlyFoundation() {
    //     require(_msgSender() == _foundation, "Only foundation allowed");
    //     _;
    // }

    receive() onlyOwner external payable {
        uint totalPower = _accumulatedStakeAmountWeight * block.timestamp - _accumulatedUnstakeAmountWeightTimestamp - (_accumulatedUnstakeAmountWeight * block.timestamp - _accumulatedUnstakeAmountWeightTimestamp) - _accumulatedTotalPower;

        _accumulatedTotalPower += totalPower;
        _bonuses.push(Bonus(msg.value, block.timestamp, totalPower));
    }

    constructor(address tokenFILGovernance, address foundation) Ownable(foundation) {
        _tokenFILGovernance = FILGovernance(tokenFILGovernance);
        // _foundation = foundation;
    }

    function stake(uint amount, uint maxStart, uint periodIndex) external{
        Period storage period = _periods[periodIndex];
        _accumulatedStakeAmountWeight += period.weight * amount;
        _accumulatedStakeAmountWeightTimestamp += _accumulatedStakeAmountWeight * block.timestamp;
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

    function getBonusByBonusIndicesStakeIndices(uint[] calldata BonusIndices, uint[] calldata stakeIndices) external returns (uint){
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
    function getBonusByBonusIndexStakeIndex(uint bonusIndex, uint stakeIndex) external returns (uint) {
        return _getBonusByBonusIndexStakeIndex(bonusIndex, stakeIndex);
    }

    function _getBonusByBonusIndexStakeIndex(uint bonusIndex, uint stakeIndex) private returns (uint) {
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
        uint power = (endTimestamp - startTimestamp) * stake.weight;
        uint amount = power * RATE_BASE / bonus.totalPower * bonus.amount / RATE_BASE;
        return amount;
    }
}