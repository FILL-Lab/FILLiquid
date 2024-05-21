// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

interface IGovernance {
    enum proposolCategory {
        filLiquid,
        fitStake,
        general
    }
    enum voteCategory {
        yes,
        no,
        noWithVeto,
        abstain
    }
    enum voteResult {
        approved,
        rejected,
        rejectedWithVeto,
        pending
    }
    struct Voting {
        uint amountTotal;
        uint[4] amounts;
    }
    struct VotingStatusInfo {
        address[] voters;
        uint amountTotal;
        uint[4] amounts;
    }
    struct VotingStatus {
        VotingStatusInfo info;
        mapping(address => Voting) voterVotings;
    }
    struct ProposalInfo {
        proposolCategory category;
        uint deadline;
        uint deposited;
        uint discussionIndex;
        bool executed;
        string text;
        address proposer;
        uint[] values;
    }
    struct Proposal {
        ProposalInfo info;
        VotingStatus status;
    }
    struct GovernanceInfo {
        uint bonders;
        uint totalBondedAmount;
        uint firstActiveProposalId;
    }
    event Proposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed discussionIndex,
        proposolCategory category,
        uint deadline,
        uint deposited,
        string text,
        uint[] values
    );
    event Bonded (
        address indexed bonder,
        uint amount
    );
    event Unbonded (
        address indexed bonder,
        uint amount
    );
    event Voted (
        address indexed voter,
        uint indexed proposalId,
        voteCategory category,
        uint amount
    );
    event Executed (
        address indexed executor,
        uint indexed proposalId,
        voteResult result
    );


    function bond(uint amount) external;

    function unbond(uint amount) external;

    function propose(proposolCategory category, uint discussionIndex, string calldata text, uint[] calldata values) external;

    function vote(uint proposalId, voteCategory category, uint amount) external;

    function execute(uint proposalId) external;

    function votingProposalSum(address bonder) external returns (uint count, uint maxVote);

    function bondedAmount(address bonder) external view returns (uint);

    function renew1stActiveProposal() external returns (uint i);

    function votedForProposal(address voter, uint proposalId) external view returns (Voting memory);

    function getStatus() external view returns (GovernanceInfo memory);

    function getProposalInfo(uint proposalId) external view returns (ProposalInfo memory);

    function getProposalCount() external view returns (uint);

    function getDepositThreshold() external view returns (uint result);

    function getVoteResult(uint proposalId) external returns (
        uint amountTotal,
        uint amountYes,
        uint amountNo,
        uint amountNoWithVeto,
        uint amountAbstain,
        voteResult result);

    function getVoteStatus(uint proposalId) external view returns (VotingStatusInfo memory);

    function getVoteStatusBrief(uint proposalId) external view returns (Voting memory);

    function canUnbond(address sender) external returns (uint, bool, string memory);

    function canPropose() external returns (bool, string memory);

    function canVote(uint proposalId, uint amount) external view returns (bool, string memory);

    function canExecute(uint proposalId) external view returns (bool, string memory);

    function getFactors() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint);

    function setFactors(
        uint new_rateBase,
        uint new_minYes,
        uint new_maxNo,
        uint new_maxNoWithVeto,
        uint new_quorum,
        uint new_liquidate,
        uint new_depositRatioThreshold,
        uint new_depositAmountThreshold,
        uint new_voteThreshold,
        uint new_votingPeriod,
        uint new_executionPeriod,
        uint new_maxActiveProposals
    ) external;

    function getContractAddrs() external view returns (address, address, address);

    function setContractAddrs(
        address new_filLiquid,
        address new_fitStake,
        address new_tokenFILGovernance
    ) external;
    function owner() external view returns (address);

    function setOwner(address new_owner) external returns (address);

}
