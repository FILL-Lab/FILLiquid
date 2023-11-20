// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./FILGovernance.sol";

contract FILGovernancePool is Context {
    enum proposolCategory {
        modifyFoundation,
        modifySigners,
        modifyVotingPeriod,
        modifyVotingThreshold,
        transferOut
    }
    enum voteCategory {
        pro,
        con
    }
    enum voteResult {
        passed,
        vetoed,
        pending
    }
    enum executionResult {
        succeeded,
        failed
    }

    struct ModifyFoundationInfo {
        address newFoundation;
    }
    struct ModifySignersInfo {
        address[] newSigners;
        uint newVotingThreshold;
    }
    struct ModifyVotingPeriodInfo {
        uint newVotingPeriod;
    }
    struct ModifyVotingThresholdInfo {
        uint newVotingThreshold;
    }
    struct TransferOutInfo {
        uint amount;
    }
    struct VotingStatusInfo {
        address[] votersPro;
        address[] votersCon;
    }
    struct VotingStatus {
        VotingStatusInfo info;
        mapping(address => bool) proed;
        mapping(address => bool) coned;
    }
    struct ProposalInfo {
        proposolCategory category;
        uint subIndex;
        uint deadline;
        bool executed;
        bool vetoed;
        string text;
        address proposer;
    }
    struct Proposal {
        ProposalInfo info;
        VotingStatus status;
    }

    event ModifyFoundationProposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed subIndex,
        proposolCategory category,
        uint deadline,
        string text,
        ModifyFoundationInfo info
    );
    event ModifySignersProposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed subIndex,
        proposolCategory category,
        uint deadline,
        string text,
        ModifySignersInfo info
    );
    event ModifyVotingPeriodProposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed subIndex,
        proposolCategory category,
        uint deadline,
        string text,
        ModifyVotingPeriodInfo info
    );
    event ModifyVotingThresholdProposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed subIndex,
        proposolCategory category,
        uint deadline,
        string text,
        ModifyVotingThresholdInfo info
    );
    event TransferOutProposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed subIndex,
        proposolCategory category,
        uint deadline,
        string text,
        TransferOutInfo info
    );
    event Voted (
        address indexed voter,
        uint indexed proposalId,
        voteCategory v
    );
    event Unvoted (
        address indexed voter,
        uint indexed proposalId
    );
    event Executed (
        address indexed executor,
        uint indexed proposalId,
        executionResult result
    );

    ModifyFoundationInfo[] private _modifyFoundationInfos;
    ModifySignersInfo[] private _modifySignersInfos;
    ModifyVotingPeriodInfo[] private _modifyVotingPeriodInfos;
    ModifyVotingThresholdInfo[] private _modifyVotingThresholdInfos;
    TransferOutInfo[] private _transferOutInfos;
    Proposal[] private _proposals;
    address[] private _signers;
    uint[5] private _currentProposalIds;
    mapping(address => bool) _isSigner;
    uint private _votingThreshold;
    uint private _votingPeriod;
    uint private _startHeight;
    uint private _totallyReleasedHeight;
    address private _foundation;
    FILGovernance private _tokenFILGovernance;

    uint constant MIN_VOTING_PERIOD = 2880; // 1 day

    constructor(address[] memory signers, address foundation, uint voteThreshold, uint votingPeriod, address tokenFILGovernance, uint totallyReleasedHeight)
    isValidVotingThreshold(voteThreshold, signers.length)
    isValidSignerCount(voteThreshold, signers.length)
    isValidVotingPeriod(votingPeriod) {
        _signers = signers;
        for (uint i = 0; i < _signers.length; i++) {
            _isSigner[_signers[i]] = true;
        }
        _foundation = foundation;
        _votingThreshold = voteThreshold;
        _votingPeriod = votingPeriod;
        _tokenFILGovernance = FILGovernance(tokenFILGovernance);
        _startHeight = block.number;
        _totallyReleasedHeight = totallyReleasedHeight;
    }

    function proposeModifyFoundation(string memory text, address newFoundation) senderIsSigner external {
        ModifyFoundationInfo memory info = ModifyFoundationInfo(newFoundation);
        _modifyFoundationInfos.push(info);
        _propose(proposolCategory.modifyFoundation, _modifyFoundationInfos.length - 1, text);
        ProposalInfo storage p = _proposals[_proposals.length - 1].info;

        emit ModifyFoundationProposed(
            p.proposer,
            _proposals.length - 1,
            p.subIndex,
            p.category,
            p.deadline,
            p.text,
            info
        );
    }

    function proposeModifySigners(string memory text, address[] memory newSigners, uint newVotingThreshold) senderIsSigner isValidSignerCount(newVotingThreshold, newSigners.length) external {
        ModifySignersInfo memory info = ModifySignersInfo(newSigners, newVotingThreshold);
        _modifySignersInfos.push(info);
        _propose(proposolCategory.modifySigners, _modifySignersInfos.length - 1, text);
        ProposalInfo storage p = _proposals[_proposals.length - 1].info;

        emit ModifySignersProposed(
            p.proposer,
            _proposals.length - 1,
            p.subIndex,
            p.category,
            p.deadline,
            p.text,
            info
        );
    }

    function proposeModifyVotingPeriod(string memory text, uint newVotingPeriod) senderIsSigner isValidVotingPeriod(newVotingPeriod) external {
        ModifyVotingPeriodInfo memory info = ModifyVotingPeriodInfo(newVotingPeriod);
        _modifyVotingPeriodInfos.push(info);
        _propose(proposolCategory.modifyVotingPeriod, _modifyVotingPeriodInfos.length - 1, text);
        ProposalInfo storage p = _proposals[_proposals.length - 1].info;

        emit ModifyVotingPeriodProposed(
            p.proposer,
            _proposals.length - 1,
            p.subIndex,
            p.category,
            p.deadline,
            p.text,
            info
        );
    }

    function proposeModifyVotingThreshold(string memory text, uint newVotingThreshold) senderIsSigner isValidVotingThreshold(newVotingThreshold, _signers.length) external {
        ModifyVotingThresholdInfo memory info = ModifyVotingThresholdInfo(newVotingThreshold);
        _modifyVotingThresholdInfos.push(info);
        _propose(proposolCategory.modifyVotingThreshold, _modifyVotingThresholdInfos.length - 1, text);
        ProposalInfo storage p = _proposals[_proposals.length - 1].info;

        emit ModifyVotingThresholdProposed(
            p.proposer,
            _proposals.length - 1,
            p.subIndex,
            p.category,
            p.deadline,
            p.text,
            info
        );
    }

    function proposeTransferOut(string memory text, uint amount) senderIsSigner external {
        TransferOutInfo memory info = TransferOutInfo(amount);
        _transferOutInfos.push(info);
        _propose(proposolCategory.transferOut, _transferOutInfos.length - 1, text);
        ProposalInfo storage p = _proposals[_proposals.length - 1].info;

        emit TransferOutProposed(
            p.proposer,
            _proposals.length - 1,
            p.subIndex,
            p.category,
            p.deadline,
            p.text,
            info
        );
    }

    function hasActiveProposal(proposolCategory category) public view returns (bool) {
        uint idplus = _currentProposalIds[uint(category)];
        if (idplus != 0) {
            ProposalInfo storage info = _proposals[idplus - 1].info;
            if (info.deadline >= block.number && !info.executed) return true;
        }
        return false;
    }

    function vote(uint proposalId, voteCategory v) senderIsSigner validProposalId(proposalId) public {
        (bool votable, string memory reason) = _canVote(_msgSender(), proposalId);
        require(votable, reason);
        _vote(proposalId, v);
    }

    function unVote(uint proposalId) senderIsSigner validProposalId(proposalId) public {
        require(hasVoted(_msgSender(), proposalId), "No voting for this proposal");
        _unVote(proposalId);
    }

    function changeVote(uint proposalId, voteCategory v) external {
        unVote(proposalId);
        vote(proposalId, v);
    }

    function execute(uint proposalId) senderIsSigner validProposalId(proposalId) external {
        (bool executable, string memory reason) = _canExecute(proposalId);
        require(executable, reason);
        _execute(proposalId);
    }

    function isSigner(address addr) external view returns (bool) {
        return _isSigner[addr];
    }

    function getProposalInfo(uint proposalId) validProposalId(proposalId) external view returns (ProposalInfo memory) {
        return _proposals[proposalId].info;
    }

    function getProposalCount() external view returns (uint) {
        return _proposals.length;
    }

    function getVoteResult(uint proposalId) validProposalId(proposalId) external view returns (voteResult) {
        if (_proposals[proposalId].status.info.votersCon.length >= _votingThreshold) return voteResult.vetoed;
        else if (_proposals[proposalId].status.info.votersPro.length >= _votingThreshold) return voteResult.passed;
        else return voteResult.pending;
    }

    function getVoteStatus(uint proposalId) validProposalId(proposalId) external view returns (VotingStatusInfo memory) {
        return _proposals[proposalId].status.info;
    }

    function hasVoted(address voter, uint proposalId) public view returns (bool) {
        return hasProed(voter, proposalId) || hasConed(voter, proposalId);
    }

    function hasProed(address voter, uint proposalId) validProposalId(proposalId) public view returns (bool) {
        return _proposals[proposalId].status.proed[voter];
    }

    function hasConed(address voter, uint proposalId) validProposalId(proposalId) public view returns (bool) {
        return _proposals[proposalId].status.coned[voter];
    }

    function getSigners() external view returns (address[] memory) {
        return _signers;
    }

    function getSignersCount() external view returns (uint) {
        return _signers.length;
    }

    function getSingleSigner(uint index) external view returns (address) {
        require(index < _signers.length, "Invalid index");
        return _signers[index];
    }

    function getModifyFoundationProposalCount() external view returns (uint) {
        return _modifyFoundationInfos.length;
    }

    function getSingleModifyFoundationProposal(uint index) external view returns (ModifyFoundationInfo memory) {
        require(index < _modifyFoundationInfos.length, "Invalid index");
        return _modifyFoundationInfos[index];
    }

    function getModifySignersProposalCount() external view returns (uint) {
        return _modifySignersInfos.length;
    }

    function getSingleModifySignersProposal(uint index) external view returns (ModifySignersInfo memory) {
        require(index < _modifySignersInfos.length, "Invalid index");
        return _modifySignersInfos[index];
    }

    function getModifyVotingPeriodProposalCount() external view returns (uint) {
        return _modifyVotingPeriodInfos.length;
    }

    function getSingleModifyVotingPeriodProposal(uint index) external view returns (ModifyVotingPeriodInfo memory) {
        require(index < _modifyVotingPeriodInfos.length, "Invalid index");
        return _modifyVotingPeriodInfos[index];
    }

    function getModifyVotingThresholdProposalCount() external view returns (uint) {
        return _modifyVotingThresholdInfos.length;
    }

    function getSingleModifyVotingThresholdProposal(uint index) external view returns (ModifyVotingThresholdInfo memory) {
        require(index < _modifyVotingThresholdInfos.length, "Invalid index");
        return _modifyVotingThresholdInfos[index];
    }

    function getTransferOutProposalCount() external view returns (uint) {
        return _transferOutInfos.length;
    }

    function getSingleTransferOutProposal(uint index) external view returns (TransferOutInfo memory) {
        require(index < _transferOutInfos.length, "Invalid index");
        return _transferOutInfos[index];
    }

    function canVote(address voter, uint proposalId) validProposalId(proposalId) external view returns (bool, string memory) {
        return _canVote(voter, proposalId);
    }

    function canExecute(uint proposalId) validProposalId(proposalId) external view returns (bool, string memory) {
        return _canExecute(proposalId);
    }

    function canRelease(uint height) public view returns (uint) {
        uint total = _tokenFILGovernance.balanceOf(address(this));
        if (_totallyReleasedHeight <= _startHeight || height >= _totallyReleasedHeight) return total;
        return (height - _startHeight) * total / (_totallyReleasedHeight - _startHeight);
    }

    function canReleaseNow() public view returns (uint) {
        return canRelease(block.number);
    }

    function getFactors() external view returns (address, uint, uint, uint, uint, uint[5] memory) {
        return (_foundation, _votingThreshold, _votingPeriod, _startHeight, _totallyReleasedHeight, _currentProposalIds);
    }

    function getFILGovernanceAddr() external view returns (address) {
        return address(_tokenFILGovernance);
    }

    modifier senderIsSigner() {
        require(_isSigner[_msgSender()], "Sender is mot signer");
        _;
    }

    modifier isValidSignerCount(uint voteThreshold, uint signerCount) {
        require(signerCount > 0, "At least one signer required");
        require(voteThreshold <= signerCount, "Invalid numbers of signers");
        _;
    }

    modifier isValidVotingPeriod(uint votingPeriod) {
        require(votingPeriod >= MIN_VOTING_PERIOD, "Invalid votingPeriod");
        _;
    }

    modifier isValidVotingThreshold(uint voteThreshold, uint signerCount) {
        require(voteThreshold > 0 && voteThreshold <= signerCount, "Invalid voteThreshold");
        _;
    }

    modifier validProposalId(uint proposalId) {
        require(proposalId < _proposals.length, "Invalid proposalId");
        _;
    }

    function _propose(proposolCategory category, uint subIndex, string memory text) private {
        bool activeProposal = hasActiveProposal(category);
        if (!activeProposal) {
            if (category == proposolCategory.modifySigners) activeProposal = hasActiveProposal(proposolCategory.modifyVotingThreshold);
            else if (category == proposolCategory.modifyVotingThreshold) activeProposal = hasActiveProposal(proposolCategory.modifySigners);
        }
        require(!activeProposal, "Active proposal of same or corresponding category exists");
        _proposals.push();
        uint proposalId = _proposals.length - 1;
        _currentProposalIds[uint(category)] = proposalId + 1;
        address proposer = _msgSender();
        ProposalInfo storage info = _proposals[proposalId].info;
        info.category = category;
        info.subIndex = subIndex;
        info.deadline = block.number + _votingPeriod;
        info.text = text;
        info.proposer = proposer;
        (bool votable,) = _canVote(proposer, proposalId);
        if (votable) _vote(proposalId, voteCategory.pro);
    }

    function _vote(uint proposalId, voteCategory v) private {
        Proposal storage p = _proposals[proposalId];
        address voter = _msgSender();
        VotingStatus storage status = p.status;
        if (v == voteCategory.pro) {
            status.proed[voter] = true;
            status.info.votersPro.push(voter);
        } else {
            status.coned[voter] = true;
            status.info.votersCon.push(voter);
        }
        (bool executable,) = _canExecute(proposalId);
        if (executable) _execute(proposalId);

        emit Voted(voter, proposalId, v);
    }

    function _unVote(uint proposalId) private {
        Proposal storage p = _proposals[proposalId];
        address voter = _msgSender();
        VotingStatus storage status = p.status;
        VotingStatusInfo storage info = status.info;
        if (status.proed[voter]) {
            delete status.proed[voter];
            _removeVoter(voter, info.votersPro);
        }
        else {
            delete status.coned[voter];
            _removeVoter(voter, info.votersCon);
        }

        emit Unvoted(voter, proposalId);
    }

    function _removeVoter(address voter, address[] storage voters) private {
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

    function _execute(uint proposalId) private {
        ProposalInfo storage info = _proposals[proposalId].info;
        VotingStatusInfo storage status = _proposals[proposalId].status.info;
        info.executed = true;
        _currentProposalIds[uint(info.category)] = 0;
        executionResult result = executionResult.succeeded;
        if (status.votersCon.length > _votingThreshold) {
            info.vetoed = true;
            result = executionResult.failed;
        } else {
            if (info.category == proposolCategory.modifyFoundation) {
            _foundation = _modifyFoundationInfos[info.subIndex].newFoundation;
            }
            else if (info.category == proposolCategory.modifySigners) {
                ModifySignersInfo storage m = _modifySignersInfos[info.subIndex];
                for (uint i = 0; i < _signers.length; i++) {
                    delete _isSigner[_signers[i]];
                }
                _signers = m.newSigners;
                for (uint i = 0; i < _signers.length; i++) {
                    _isSigner[_signers[i]] = true;
                }
                _votingThreshold = m.newVotingThreshold;
            } else if (info.category == proposolCategory.modifyVotingPeriod) {
                _votingPeriod = _modifyVotingPeriodInfos[info.subIndex].newVotingPeriod;
            } else if (info.category == proposolCategory.modifyVotingThreshold) {
                _votingThreshold = _modifyVotingThresholdInfos[info.subIndex].newVotingThreshold;
            } else if (info.category == proposolCategory.transferOut) {
                uint amount = _transferOutInfos[info.subIndex].amount;
                require (amount <= canReleaseNow(), "Invalid amount");
                _tokenFILGovernance.transfer(_foundation, amount);
            } else revert("Invalid category");
        }
        
        emit Executed(_msgSender(), proposalId, result);
    }

    function _canVote(address voter, uint proposalId) private view returns (bool, string memory) {
        Proposal storage p = _proposals[proposalId];
        if (p.info.deadline < block.number) return (false, "Proposal finished");
        if (hasVoted(voter,proposalId)) return (false, "Already voted");
        else return (true, "");
    }

    function _canExecute(uint proposalId) private view returns (bool, string memory) {
        Proposal storage p = _proposals[proposalId];
        if (p.info.deadline < block.number) return (false, "Proposal finished");
        if (p.info.executed) return (false, "Already executed");
        VotingStatusInfo storage info = p.status.info;
        if (info.votersPro.length < _votingThreshold && info.votersPro.length < _votingThreshold) return (false, "Not enough votes");
        else return (true, "");
    }
}
