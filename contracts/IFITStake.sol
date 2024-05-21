// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./Utils/ICalculation.sol";

interface IFITStake {
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

    function handleInterest(address minter, uint principal, uint interest) external returns (uint minted);

    function stakeFilTrust(uint amount, uint maxStart, uint duration) external returns (uint minted);

    function unStakeFilTrust(uint stakeId) external returns (uint minted, uint withdrawnFIG);

    function withdrawFIG(uint stakeId) external returns (uint withdrawn);

    function canWithDrawFIG(uint stakeId) external view returns(uint canWithdraw);

    function withdrawFIGAll() external returns (uint withdrawn);

    function canWithdrawFIGAll(address staker) external view returns (uint withdrawn);
    
    function onceStaked(address staker) external view returns (bool);

    function getStakersCount() external view returns (uint);

    function getStakersSubset(uint start, uint end) external view returns (StakerInfo[] memory result);

    function getStakerStakes(address staker) external view returns (StakerInfo memory result);

    function getStakerTerms(address staker) external view returns (uint stakeSum, uint totalFIGSum, uint releasedFIGSum, uint canWithdrawFITSum, uint canWithdrawFIGSum);


    /*function getStakeInfoByPos(address staker, uint pos) external view returns (StakeInfo memory result) {
        Stake[] storage stakes = _stakerStakes[staker].stakes;
        require(pos < stakes.length, "Invalid pos");
        result.stake = stakes[pos];
        result.canWithdraw = block.number >= stakes[pos].end;
    }*/

    function getStakerById(uint stakeId) external view returns (address);

    function getStakeInfoById(uint stakeId) external view returns (StakeInfo memory);

    function getStakeInfoByStakerAndId(address staker, uint stakeId) external view returns (StakeInfo memory result);

    function getStakerSum(address staker) external view returns (uint);

    function getCurrentMintedFromInterest(uint amount) external view returns (uint, uint);

    function getCurrentMintedFromStake(uint stake, uint duration) external view returns (uint, uint);

    function getStatus() external view returns (FITStakeInfo memory);

    function setShares(uint new_rateBase, uint new_interest_share, uint new_stake_share) external;

    function setStakeParams(uint new_minStakePeriod, uint new_maxStakePeriod, uint new_minStake, uint new_maxStakes) external;

    function setGovernanceFactors(uint[] calldata params) external;

    function checkGovernanceFactors(uint[] calldata params) external pure;

    function getAllFactors() external view returns (uint[9] memory result);

    function getContractAddrs() external view returns (address, address, address, address, address);

    function setContractAddrs(
        address new_filLiquid,
        address new_governance,
        address new_tokenFILTrust,
        address new_calculation,
        address new_tokenFILGovernance
    ) external;

    function owner() external view returns (address);

    function setOwner(address new_owner) external; 

}
