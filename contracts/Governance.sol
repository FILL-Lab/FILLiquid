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

    struct Proposal {
        proposolCategory category;
        uint deadline;
        uint modificationline;
        uint deposited;
        uint discussionIndex;
        bool executed;
        string text;
        address proposer;
        uint[] values;
        VotingStatus status;
    }

    event Proposed (
        uint proposalId,
        proposolCategory category,
        uint deadline,
        uint modificationline,
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

    event Withdrawn (
        uint proposalId,
        voteCategory category,
        uint amount,
        address voter
    );

    event Executed (
        uint proposalId,
        bool success
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
    uint private _depositThreshold;
    uint private _voteThreshold;
    uint private _votingPeriod;
    uint private _modifiablePeriod;
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
    uint constant DEFAULT_DEPOSIT_THRESHOLD = 1e22; // TODO: discuss about the value
    uint constant DEFAULT_VOTE_THRESHOLD = 1e20; // TODO: discuss about the value
    uint constant DEFAULT_VOTING_PERIOD = 40320; // 14 days, todo: discuss about the value
    uint constant DEFAULT_MODIFIABLE_PERIOD = 25920; // 9 days, todo: discuss about the value
    uint constant DEFAULT_EXECUTION_PERIOD = 40320; // 14 days, todo: discuss about the value
    uint constant DEFAULT_MAX_ACTIVE_PROPOSAL = 1000; // todo: discuss about the value

    constructor() {
        _owner = _msgSender();

        _rateBase = DEFAULT_RATEBASE;
        _minYes = DEFAULT_MIN_YES;
        _maxNo = DEFAULT_MAX_NO;
        _maxNoWithVeto = DEFAULT_MAX_NO_WITH_VETO;
        _quorum = DEFAULT_QUORUM;
        _depositThreshold = DEFAULT_DEPOSIT_THRESHOLD;
        _voteThreshold = DEFAULT_VOTE_THRESHOLD;
        _votingPeriod = DEFAULT_VOTING_PERIOD;
        _modifiablePeriod = DEFAULT_MODIFIABLE_PERIOD;
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

    function unbond(uint amount) noVoting external {
        address sender = _msgSender();
        require(_bondings[sender] > 0, "Not bonded");
        require(amount <= _bondings[sender], "Invalid amount");
        if (amount == 0) amount = _bondings[sender];
        _bondings[sender] -= amount;
        _totalBondedAmount -= amount;
        if (_bondings[sender] == 0) _bonders--;
        _tokenFILGovernance.transfer(sender, amount);

        emit Unbonded(sender, amount);
    }

    function propose(proposolCategory category, uint discussionIndex, string memory text, uint[] memory values) external {
        require (_proposals.length - getFirstVotingProposal() < _maxActiveProposal, "Max active proposals reached");
        _checkParameter(category, values);
        address sender = _msgSender();
        _tokenFILGovernance.claim(sender, _depositThreshold);
        _proposals.push();
        Proposal storage p = _proposals[_proposals.length - 1];
        p.category = category;
        p.deadline = block.number + _votingPeriod;
        p.modificationline = block.number + _modifiablePeriod;
        p.deposited = _depositThreshold;
        p.discussionIndex = discussionIndex;
        p.text = text;
        p.proposer = sender;
        p.values = values;

        emit Proposed(_proposals.length - 1, p.category, p.deadline, p.modificationline, p.deposited, p.discussionIndex, p.text, p.proposer, p.values);
    }

    function vote(uint proposalId, voteCategory category, uint amount) external validProposalId(proposalId) {
        Proposal storage p = _proposals[proposalId];
        require(p.deadline >= block.number, "Proposal finished");
        address voter = _msgSender();
        require(amount >= _voteThreshold, "Voting amount too low");
        VotingStatus storage status = p.status;
        Voting storage voting = status.voterVotings[voter];
        if (voting.amountTotal == 0) status.voters.push(voter);
        require(voting.amountTotal + amount <= _bondings[voter], "Invalid amount");
        status.amountTotal += amount;
        status.amounts[uint(category)] += amount;
        voting.amountTotal += amount;
        voting.amounts[uint(category)] += amount;

        emit Voted(proposalId, category, amount, voter);
    }

    function withdraw(uint proposalId, voteCategory category, uint amount) external validProposalId(proposalId) {
        Proposal storage p = _proposals[proposalId];
        require(p.modificationline >= block.number, "Proposal finished");
        address voter = _msgSender();
        VotingStatus storage status = p.status;
        Voting storage voting = status.voterVotings[voter];
        uint maxAmount = voting.amounts[uint(category)];
        require(amount <= maxAmount, "Invalid amount");
        if (amount == 0) amount = maxAmount;
        status.amountTotal -= amount;
        status.amounts[uint(category)] -= amount;
        voting.amountTotal -= amount;
        voting.amounts[uint(category)] -= amount;
        if (voting.amountTotal == 0) {
            address[] storage voters = status.voters;
            for (uint i = 0; i < voters.length; i++) {
                if (voters[i] == voter) {
                    if (i != voters.length - 1) {
                        voters[i] = voters[voters.length - 1];
                    }
                    voters.pop();
                    break;
                }
            }
        }

        emit Withdrawn(proposalId, category, amount, voter);
    }

    function execute(uint proposalId) external validProposalId(proposalId) {
        Proposal storage p = _proposals[proposalId];
        require(p.deadline < block.number, "Proposal voting in progress");
        require(p.deadline + _executionPeriod >= block.number, "Proposal expired");
        require(!p.executed, "Already executed");
        _nextProposalId = proposalId + 1;
        p.executed = true;
        VotingStatus storage status = p.status;
        bool success;
        if ((status.amounts[uint(voteCategory.no)] + status.amounts[uint(voteCategory.noWithVeto)]) * _rateBase < status.amountTotal * _maxNo && 
        status.amounts[uint(voteCategory.yes)] * _rateBase >= status.amountTotal * _minYes &&
        status.amountTotal * _rateBase >= _totalBondedAmount * _quorum) {
            success = true;
            if (p.category == proposolCategory.filLiquid) _filLiquid.setBorrowPayBackFactors(p.values);
            else if (p.category == proposolCategory.filStake) _filStake.setGovernanceFactors(p.values);
        }
        if (status.amounts[uint(voteCategory.noWithVeto)] * _rateBase < status.amountTotal * _maxNoWithVeto) {
            _tokenFILGovernance.transfer(p.proposer, p.deposited);
        } else {
            _tokenFILGovernance.burn(address(this), p.deposited);
        }

        emit Executed(proposalId, success);
    }

    function votingProposalCounts(address bonder) public view returns (uint count) {
        for (uint i = getFirstVotingProposal(); i < _proposals.length; i++) {
            if (_proposals[i].status.voterVotings[bonder].amountTotal > 0) count++;
        }
    }

    function bondedAmount(address bonder) external view returns (uint) {
        return _bondings[bonder];
    }

    function getFirstVotingProposal() public view returns (uint i) {
        for (i = _nextProposalId; i < _proposals.length; i++) {
            if (_proposals[i].deadline >= block.number) break;
        }
    }

    function votedForProposal(address bonder, uint proposalId) external validProposalId(proposalId) view returns (Voting memory) {
        return _proposals[proposalId].status.voterVotings[bonder];
    }

    function getStatus() external view returns (uint, uint, uint) {
        return (_bonders, _totalBondedAmount, _nextProposalId);
    }

    /*function proposals() external view returns (Proposal[] memory) {
        return _proposals;
    }

    function specifiedProposal(uint index) external view returns (Proposal memory) {
        return _proposals[index];
    }*/

    function proposalCount() external view returns (uint) {
        return _proposals.length;
    } 

    function getFactors() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        return (_rateBase, _minYes, _maxNo, _maxNoWithVeto, _quorum, _depositThreshold, _voteThreshold, _votingPeriod, _modifiablePeriod, _executionPeriod, _maxActiveProposal);
    }

    function setFactors(
        uint new_rateBase,
        uint new_minYes,
        uint new_maxNo,
        uint new_maxNoWithVeto,
        uint new_quorum,
        uint new_depositThreshold,
        uint new_voteThreshold,
        uint new_votingPeriod,
        uint new_modifiablePeriod,
        uint new_executionPeriod,
        uint new_maxActiveProposal
    ) onlyOwner external {
        require(
            new_minYes <= new_rateBase &&
            new_maxNo <= new_rateBase &&
            new_maxNoWithVeto <= new_rateBase &&
            new_quorum <= new_rateBase &&
            new_modifiablePeriod <= new_votingPeriod, "Invalid factor");
        _rateBase = new_rateBase;
        _minYes = new_minYes;
        _maxNo = new_maxNo;
        _maxNoWithVeto = new_maxNoWithVeto;
        _quorum = new_quorum;
        _depositThreshold = new_depositThreshold;
        _voteThreshold = new_voteThreshold;
        _votingPeriod = new_votingPeriod;
        _modifiablePeriod = new_modifiablePeriod;
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

    modifier noVoting() {
        require(votingProposalCounts(_msgSender()) == 0, "With votings");
        _;
    }

    function _checkParameter(proposolCategory category, uint[] memory params) private view {
        if (category == proposolCategory.filLiquid) {
            _filLiquid.checkBorrowPayBackFactors(params);
        }
        else if (category == proposolCategory.filStake) {
            _filStake.checkGovernanceFactors(params);
        } else {
            require(params.length == 0, "Invalid input length");
        }
    }
}
