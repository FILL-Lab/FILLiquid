// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./FILLiquid.sol";
import "./FILStake.sol";
import "./FILGovernance.sol";

contract Governance is Context {
    enum proposolCategory {
        filLiquid,
        filStake,
        general
    }

    enum voteCategory {
        yes,
        no,
        noWithVeto,
        abstain
    }

    enum voteResult {
        success,
        fail,
        failWithVeto,
        pending
    }

    struct Voting {
        uint amountTotal;
        uint[4] amounts;
    }

    struct VotingStatus {
        address[] voters;
        mapping(address => Voting) voterVotings;
        uint amountTotal;
        uint[4] amounts;
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

    event Proposed (
        uint proposalId,
        proposolCategory category,
        uint deadline,
        uint deposited,
        uint discussionIndex,
        string text,
        address proposer,
        uint[] values
    );

    event Bonded (
        address bonder,
        uint amount
    );

    event Unbonded (
        address bonder,
        uint amount
    );

    event Voted (
        uint proposalId,
        voteCategory category,
        uint amount,
        address voter
    );

    event Executed (
        uint proposalId,
        voteResult result,
        address executor
    );

    mapping(address => uint) private _bondings;
    Proposal[] private _proposals;
    uint private _bonders;
    uint private _totalBondedAmount;
    uint private _nextProposalId;
    uint private _rateBase;
    uint private _minYes;
    uint private _maxNo;
    uint private _maxNoWithVeto;
    uint private _quorum;
    uint private _liquidate;
    uint private _depositThreshold;
    uint private _voteThreshold;
    uint private _votingPeriod;
    uint private _executionPeriod;
    uint private _maxActiveProposal;
    address private _owner;

    FILLiquid private _filLiquid;
    FILStake private _filStake;
    FILGovernance private _tokenFILGovernance;

    uint constant DEFAULT_RATEBASE = 1000000;
    uint constant DEFAULT_MIN_YES = 500000;
    uint constant DEFAULT_MAX_NO = 333333;
    uint constant DEFAULT_MAX_NO_WITH_VETO = 333333;
    uint constant DEFAULT_QUORUM = 400000;
    uint constant DEFAULT_LIQUIDATE = 200000;
    uint constant DEFAULT_DEPOSIT_THRESHOLD = 5e20;
    uint constant DEFAULT_VOTE_THRESHOLD = 1e19;
    uint constant DEFAULT_VOTING_PERIOD = 40320; // 14 days
    uint constant DEFAULT_EXECUTION_PERIOD = 20160; // 7 days
    uint constant DEFAULT_MAX_ACTIVE_PROPOSAL = 1000;

    constructor() {
        _owner = _msgSender();

        _rateBase = DEFAULT_RATEBASE;
        _minYes = DEFAULT_MIN_YES;
        _maxNo = DEFAULT_MAX_NO;
        _maxNoWithVeto = DEFAULT_MAX_NO_WITH_VETO;
        _quorum = DEFAULT_QUORUM;
        _liquidate = DEFAULT_LIQUIDATE;
        _depositThreshold = DEFAULT_DEPOSIT_THRESHOLD;
        _voteThreshold = DEFAULT_VOTE_THRESHOLD;
        _votingPeriod = DEFAULT_VOTING_PERIOD;
        _executionPeriod = DEFAULT_EXECUTION_PERIOD;
        _maxActiveProposal = DEFAULT_MAX_ACTIVE_PROPOSAL;
    }

    function bond(uint amount) external {
        address sender = _msgSender();
        _tokenFILGovernance.claim(sender, amount);
        if (_bondings[sender] == 0) _bonders++;
        _bondings[sender] += amount;
        _totalBondedAmount += amount;

        emit Bonded(sender, amount);
    }

    function unbond(uint amount) external {
        address sender = _msgSender();
        require(_bondings[sender] > 0, "Not bonded");
        (, uint maxVote) = votingProposalSum(sender);
        require(amount <= _bondings[sender] - maxVote, "Invalid amount");
        if (amount == 0) amount = _bondings[sender];
        _bondings[sender] -= amount;
        _totalBondedAmount -= amount;
        if (_bondings[sender] == 0) _bonders--;
        _tokenFILGovernance.transfer(sender, amount);

        emit Unbonded(sender, amount);
    }

    function propose(proposolCategory category, uint discussionIndex, string memory text, uint[] memory values) external {
        require (_proposals.length - renewFirstVotingProposal() < _maxActiveProposal, "Max active proposals reached");
        _checkParameter(category, values);
        address sender = _msgSender();
        _tokenFILGovernance.claim(sender, _depositThreshold);
        _proposals.push();
        ProposalInfo storage info = _proposals[_proposals.length - 1].info;
        info.category = category;
        info.deadline = block.number + _votingPeriod;
        info.deposited = _depositThreshold;
        info.discussionIndex = discussionIndex;
        info.text = text;
        info.proposer = sender;
        info.values = values;

        emit Proposed(
            _proposals.length - 1,
            info.category,
            info.deadline,
            info.deposited,
            info.discussionIndex,
            info.text,
            info.proposer,
            info.values
        );
    }

    function vote(uint proposalId, voteCategory category, uint amount) validProposalId(proposalId) external {
        Proposal storage p = _proposals[proposalId];
        ProposalInfo storage info = p.info;
        VotingStatus storage status = p.status;
        address voter = _msgSender();
        Voting storage voting = status.voterVotings[voter];
        require(amount >= _voteThreshold, "Voting amount too low");
        require(info.deadline >= block.number, "Proposal finished");
        require(voting.amountTotal + amount <= _bondings[voter], "Invalid amount");
        if (voting.amountTotal == 0) status.voters.push(voter);
        status.amountTotal += amount;
        status.amounts[uint(category)] += amount;
        voting.amountTotal += amount;
        voting.amounts[uint(category)] += amount;

        emit Voted(proposalId, category, amount, voter);
    }

    function execute(uint proposalId) validProposalId(proposalId) external {
        Proposal storage p = _proposals[proposalId];
        ProposalInfo storage info = p.info;
        VotingStatus storage status = p.status;
        address sender = _msgSender();
        require(info.deadline < block.number, "Proposal voting in progress");
        require(!info.executed, "Already executed");
        info.executed = true;
        if (_nextProposalId <= proposalId) {
            _nextProposalId = proposalId + 1;
        }
        voteResult result = _voteResult(status);
        if (result == voteResult.failWithVeto) {
            (uint liquidate, uint remain) = _liquidateResult(info.deposited);
            _tokenFILGovernance.transfer(sender, liquidate);
            _tokenFILGovernance.burn(address(this), remain);
        } else {
            if (info.deadline + _executionPeriod >= block.number) {
                if (result == voteResult.success) {
                    if (info.category == proposolCategory.filLiquid) _filLiquid.setBorrowPayBackFactors(info.values);
                    else if (info.category == proposolCategory.filStake) _filStake.setGovernanceFactors(info.values);
                }
                _tokenFILGovernance.transfer(info.proposer, info.deposited);
            } else {
                (uint liquidate, uint remain) = _liquidateResult(info.deposited);
                _tokenFILGovernance.transfer(sender, liquidate);
                _tokenFILGovernance.transfer(info.proposer, remain);
            }
        }

        emit Executed(proposalId, result, _msgSender());
    }

    function votingProposalSum(address bonder) public returns (uint count, uint maxVote) {
        for (uint i = renewFirstVotingProposal(); i < _proposals.length; i++) {
            uint amount = _proposals[i].status.voterVotings[bonder].amountTotal;
            if (amount > 0) {
                if (amount > maxVote) maxVote = amount;
                count++;
            }
        }
    }

    function bondedAmount(address bonder) external view returns (uint) {
        return _bondings[bonder];
    }

    function renewFirstVotingProposal() public returns (uint i) {
        for (i = _nextProposalId; i < _proposals.length; i++) {
            if (_proposals[i].info.deadline >= block.number) break;
        }
        _nextProposalId = i;
    }

    function votedForProposal(address voter, uint proposalId) validProposalId(proposalId) external view returns (Voting memory) {
        return _proposals[proposalId].status.voterVotings[voter];
    }

    function getStatus() external view returns (uint, uint, uint) {
        return (_bonders, _totalBondedAmount, _nextProposalId);
    }

    function getProposalInfo(uint proposalId) validProposalId(proposalId) external view returns (ProposalInfo memory) {
        return _proposals[proposalId].info;
    }

    function proposalCount() external view returns (uint) {
        return _proposals.length;
    }

    function getVoteResult(uint proposalId) validProposalId(proposalId) external view returns (
        uint amountTotal,
        uint amountYes,
        uint amountNo,
        uint amountNoWithVeto,
        uint amountAbstain,
        voteResult result) {
        VotingStatus storage status = _proposals[proposalId].status;
        amountTotal = status.amountTotal;
        amountYes = status.amounts[uint(voteCategory.yes)];
        amountNo = status.amounts[uint(voteCategory.no)];
        amountNoWithVeto = status.amounts[uint(voteCategory.noWithVeto)];
        amountAbstain = status.amounts[uint(voteCategory.abstain)];
        result = _voteResult(status);
    }

    function getFactors() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        return (_rateBase, _minYes, _maxNo, _maxNoWithVeto, _quorum, _liquidate, _depositThreshold, _voteThreshold, _votingPeriod, _executionPeriod, _maxActiveProposal);
    }

    function setFactors(
        uint new_rateBase,
        uint new_minYes,
        uint new_maxNo,
        uint new_maxNoWithVeto,
        uint new_quorum,
        uint new_liquidate,
        uint new_depositThreshold,
        uint new_voteThreshold,
        uint new_votingPeriod,
        uint new_executionPeriod,
        uint new_maxActiveProposal
    ) onlyOwner external {
        require(
            new_minYes <= new_rateBase &&
            new_maxNo <= new_rateBase &&
            new_maxNoWithVeto <= new_rateBase &&
            new_quorum <= new_rateBase &&
            new_liquidate <= new_rateBase, "Invalid factor");
        _rateBase = new_rateBase;
        _minYes = new_minYes;
        _maxNo = new_maxNo;
        _maxNoWithVeto = new_maxNoWithVeto;
        _quorum = new_quorum;
        _liquidate = new_liquidate;
        _depositThreshold = new_depositThreshold;
        _voteThreshold = new_voteThreshold;
        _votingPeriod = new_votingPeriod;
        _executionPeriod = new_executionPeriod;
        _maxActiveProposal = new_maxActiveProposal;
    }

    function getContactAddrs() external view returns (address, address, address) {
        return (address(_filLiquid), address(_filStake), address(_tokenFILGovernance));
    }

    function setContactAddrs(
        address new_filLiquid,
        address new_filStake,
        address new_tokenFILGovernance
    ) onlyOwner external {
        _filLiquid = FILLiquid(new_filLiquid);
        _filStake = FILStake(new_filStake);
        _tokenFILGovernance = FILGovernance(new_tokenFILGovernance);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external returns (address) {
        _owner = new_owner;
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner allowed");
        _;
    }

    modifier validProposalId(uint proposalId) {
        require(proposalId < _proposals.length, "Invalid proposalId");
        _;
    }

    function _checkParameter(proposolCategory category, uint[] memory params) private view {
        if (category == proposolCategory.filLiquid) {
            _filLiquid.checkBorrowPayBackFactors(params);
        } else if (category == proposolCategory.filStake) {
            _filStake.checkGovernanceFactors(params);
        } else {
            require(params.length == 0, "Invalid input length");
        }
    }

    function _voteResult(VotingStatus storage status) private view returns (voteResult result) {
        uint amountTotal = status.amountTotal;
        uint amountYes = status.amounts[uint(voteCategory.yes)];
        uint amountNo = status.amounts[uint(voteCategory.no)];
        uint amountNoWithVeto = status.amounts[uint(voteCategory.noWithVeto)];
        if (amountNoWithVeto * _rateBase >= amountTotal * _maxNoWithVeto) {
            result = voteResult.failWithVeto;
        } else if ((amountNo + amountNoWithVeto) * _rateBase >= amountTotal * _maxNo) {
            result = voteResult.fail;
        } else if (amountYes * _rateBase >= amountTotal * _minYes && amountTotal * _rateBase >= _totalBondedAmount * _quorum) {
            result = voteResult.success;
        } else {
            result = voteResult.pending;
        }
    }

    function _liquidateResult(uint amount) private view returns (uint liquidate, uint remain) {
        liquidate = amount * _liquidate;
        if (liquidate % _rateBase == 0) liquidate /= _rateBase;
        else liquidate = liquidate / _rateBase + 1;
        remain = amount - liquidate;
    }
}
