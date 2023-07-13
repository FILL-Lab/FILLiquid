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
        governance,
        general
    }

    enum voteCategory {
        yes,
        no,
        noWithVeto,
        abstain
    }

    struct Voting {
        voteCategory category;
        uint amount;
        address voter;
        bool withdrawn;
    }

    struct VotingStatus {
        Voting[] votings;
        uint countTotal;
        uint countYes;
        uint countNo;
        uint countNoWithVeto;
        uint countAbstain;
    }

    struct Proposal {
        proposolCategory category;
        uint deadline;
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
        uint deposited,
        uint discussionIndex,
        string text,
        address proposer,
        uint[] values
    );

    event Voted (
        uint proposalId,
        voteCategory category,
        uint amount,
        address voter
    );

    event Executed (
        uint proposalId,
        bool success
    );

    event Withdrawn (
        uint proposalId,
        uint votingId
    );

    Proposal[] private _proposals;
    uint private _rateBase;
    uint private _minYes;
    uint private _maxNo;
    uint private _maxNoWithVeto;
    uint private _depositThreshold;
    uint private _votingPeriod;
    uint private _executionPeriod;
    address private _owner;

    FILLiquid private _filLiquid;
    FILStake private _filStake;
    FILGovernance private _tokenFILGovernance;

    uint constant DEFAULT_RATEBASE = 1000000;
    uint constant DEFAULT_MIN_YES = 500000;
    uint constant DEFAULT_MAX_NO = 333333;
    uint constant DEFAULT_MAX_NO_WITH_VETO = 333333;
    uint constant DEFAULT_DEPOSIT_THRESHOLD = 1e22; // TODO: discuss about the value
    uint constant DEFAULT_VOTING_PERIOD = 40320; // 14 days, todo: discuss about the value
    uint constant DEFAULT_EXECUTION_PERIOD = 40320; // 14 days, todo: discuss about the value

    constructor() {
        _owner = _msgSender();

        _rateBase = DEFAULT_RATEBASE;
        _minYes = DEFAULT_MIN_YES;
        _maxNo = DEFAULT_MAX_NO;
        _maxNoWithVeto = DEFAULT_MAX_NO_WITH_VETO;
        _depositThreshold = DEFAULT_DEPOSIT_THRESHOLD;
        _votingPeriod = DEFAULT_VOTING_PERIOD;
        _executionPeriod = DEFAULT_EXECUTION_PERIOD;
    }

    function propose(proposolCategory category, uint discussionIndex, string memory text, uint[] memory values) external {
        _checkParameter(category, values);
        address sender = _msgSender();
        require(_tokenFILGovernance.allowance(sender, address(this)) >= _depositThreshold, "Allowance not enough");
        _tokenFILGovernance.transferFrom(sender, address(this), _depositThreshold);
        _proposals.push();
        Proposal storage p = _proposals[_proposals.length - 1];
        p.category = category;
        p.deadline = block.number + _votingPeriod;
        p.deposited = _depositThreshold;
        p.discussionIndex = discussionIndex;
        p.text = text;
        p.proposer = sender;
        p.values = values;

        emit Proposed(_proposals.length - 1, p.category, p.deadline, p.deposited, p.discussionIndex, p.text, p.proposer, p.values);
    }

    //Todo: Add change or cancel vote?
    function vote(uint proposalId, voteCategory category, uint amount) external validProposalId(proposalId) {
        Proposal storage p = _proposals[proposalId];
        require(p.deadline >= block.number, "Proposal finished");
        address voter = _msgSender();
        require(_tokenFILGovernance.allowance(voter, address(this)) >= amount, "Allowance not enough");
        _tokenFILGovernance.transferFrom(voter, address(this), amount);
        VotingStatus storage s = p.status;
        s.votings.push(Voting(category, amount, voter, false));
        s.countTotal += amount;
        if (category == voteCategory.yes) s.countYes += amount;
        else if (category == voteCategory.no) s.countNo += amount;
        else if (category == voteCategory.noWithVeto) s.countNoWithVeto += amount;
        else s.countAbstain += amount;

        emit Voted(proposalId, category, amount, voter);
    }

    function execute(uint proposalId) external validProposalId(proposalId) {
        Proposal storage p = _proposals[proposalId];
        require(p.deadline < block.number, "Proposal voting in progress");
        require(p.deadline + _executionPeriod >= block.number, "Proposal expired");
        require(!p.executed, "Already executed");
        p.executed = true;
        VotingStatus storage s = p.status;
        bool success;
        if ((s.countNo + s.countNoWithVeto) * _rateBase < s.countTotal * _maxNo && 
        s.countYes * _rateBase >= s.countTotal * _minYes) {
            success = true;
            if (p.category == proposolCategory.filLiquid) _filLiquid.setBorrowPayBackFactors(p.values);
            else if (p.category == proposolCategory.filStake) _filStake.setFactors(p.values);
            else if (p.category == proposolCategory.governance) _setFactors(p.values);
        }
        //Todo: whether burn or transfer?
        if (s.countNoWithVeto * _rateBase < s.countTotal * _maxNoWithVeto) {
            _tokenFILGovernance.transfer(p.proposer, p.deposited);
        } else {
            _tokenFILGovernance.burn(address(this), p.deposited);
        }

        emit Executed(proposalId, success);
    }

    function withdraw(uint proposalId, uint votingId) external validProposalId(proposalId) {
        Proposal storage p = _proposals[proposalId];
        require(p.deadline < block.number, "Proposal not finished");
        require(votingId < p.status.votings.length, "Invalid votingId");
        Voting storage v = p.status.votings[votingId];
        require(!v.withdrawn, "Already withdrawn");
        v.withdrawn = true;
        _tokenFILGovernance.transfer(v.voter, v.amount);

        emit Withdrawn(proposalId, votingId);
    }

    function proposals() external view returns (Proposal[] memory) {
        return _proposals;
    }

    function specifiedProposal(uint index) external view returns (Proposal memory) {
        return _proposals[index];
    }

    function proposalCount() external view returns (uint) {
        return _proposals.length;
    } 

    function getFactors() external view returns (uint, uint, uint, uint, uint, uint, uint) {
        return (_rateBase, _minYes, _maxNo, _maxNoWithVeto, _depositThreshold, _votingPeriod, _executionPeriod);
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
        }
        else if (category == proposolCategory.filStake) {
            _filStake.checkFactors(params);
        }
        else if (category == proposolCategory.governance) {
            _checkFactors(params);
        }
    }

    function _setFactors(uint[] storage params) private {
        _rateBase = params[0];
        _minYes = params[1];
        _maxNo = params[2];
        _maxNoWithVeto = params[3];
        _depositThreshold = params[4];
        _votingPeriod = params[5];
        _executionPeriod = params[6];
    }

    function _checkFactors(uint[] memory params) public pure {
        require(params.length == 7, "Invalid input length");
        require(params[1] <= params[0], "Invalid new_minYes");
        require(params[2] <= params[0], "Invalid new_maxNo");
        require(params[3] <= params[0], "Invalid new_maxNoWithVeto");
    }
}
