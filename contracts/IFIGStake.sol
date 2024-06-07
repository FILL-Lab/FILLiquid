// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


import "./FILGovernance.sol";

interface IFIGStake {

    event EventStake(uint index);
    event EventUnstake(uint index);
    event EventWithdrawn(uint bonusIndex, uint stakeIndex);
    event EventBouns(index);

    // 质押
    struct Stake {
        address staker;
        uint amount;
        uint weight;
        uint startTimestamp;
        uint endTimestamp;
        bool unstaked;
    }

    // 分红池
    struct Bonus {
        uint amount;
        uint timestamp;
        uint totalPower;
    }

    // 抵押时间和权重
    struct Period {
        uint weight;
        uint duration;
    }

    Stake[] public _stakes;
    Bonus[] public _bonuses;
    Period[] public _periods;

    function stake(uint amount, uint maxStart, uint periodIndex) external;
    function unstake(uint64 index) external;

    // 根据index和质押index提出所有分红
    function withdrawByBonusIndicesStakeIndices(uint[] calldata bonusIndices, uint[] calldata stakeIndices, address to) external;

    // 根据index和质押index获取总分红金额
    function getBonusByBonusIndicesStakeIndices(uint[] calldata BonusIndices, uint[] calldata stakeIndices) external returns (uint);

    // 根据index和质押index获取单个分红金额
    function getBonusByBonusIndexStakeIndex(uint bonusIndex, uint stakeIndex) external returns (uint);
}