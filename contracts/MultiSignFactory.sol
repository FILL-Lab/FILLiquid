// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

contract MultiSignFactory is Context {
    enum proposolCategory {
        modifySigners,
        outerProposal
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
    struct ModifySignersInfo {
        address[] newSigners;
        uint newVotingThreshold;
    }
    struct OuterProposalInfo {
        address target;
        bytes code;
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
        address proposer;
        uint subIndex;
        bool executed;
        bool vetoed;
        string text;
    }
    struct Proposal {
        ProposalInfo info;
        VotingStatus status;
    }

    event ModifySignersProposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed subIndex,
        string text,
        ModifySignersInfo info
    );
    event OuterProposalProposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed subIndex,
        string text,
        OuterProposalInfo info
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
    event ModifySignersExecuted (
        address indexed executor,
        uint indexed proposalId,
        executionResult result
    );
    event OuterProposalExecuted (
        address indexed executor,
        uint indexed proposalId,
        executionResult result,
        bool success,
        bytes output
    );

    ModifySignersInfo[] private _modifySignersInfos;
    OuterProposalInfo[] private _outerProposalInfos;
    Proposal[] private _proposals;
    address[] private _signers;
    mapping(address => bool) _isSigner;
    uint private _votingThreshold;

    constructor(address[] memory signers, uint voteThreshold)
    isValidSignerCount(voteThreshold, signers.length) {
        _signers = signers;
        for (uint i = 0; i < _signers.length; i++) {
            _isSigner[_signers[i]] = true;
        }
        _votingThreshold = voteThreshold;
    }

    function proposeModifySigners(string calldata text, address[] calldata newSigners, uint newVotingThreshold) senderIsSigner isValidSignerCount(newVotingThreshold, newSigners.length) external {
        ModifySignersInfo memory info = ModifySignersInfo(newSigners, newVotingThreshold);
        _modifySignersInfos.push(info);
        _propose(proposolCategory.modifySigners, _modifySignersInfos.length - 1, text);
        ProposalInfo storage p = _proposals[_proposals.length - 1].info;

        emit ModifySignersProposed(
            p.proposer,
            _proposals.length - 1,
            p.subIndex,
            p.text,
            info
        );
    }

    function proposeOuterProposal(string calldata text, address target, bytes calldata code) senderIsSigner external payable {
        OuterProposalInfo memory info = OuterProposalInfo(target, code);
        _outerProposalInfos.push(info);
        _propose(proposolCategory.outerProposal, _outerProposalInfos.length - 1, text);
        ProposalInfo storage p = _proposals[_proposals.length - 1].info;

        emit OuterProposalProposed(
            p.proposer,
            _proposals.length - 1,
            p.subIndex,
            p.text,
            info
        );
    }

    function vote(uint proposalId, voteCategory v) senderIsSigner validProposalId(proposalId) public payable {
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

    function execute(uint proposalId) senderIsSigner validProposalId(proposalId) external payable {
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

    function getModifySignersProposalCount() external view returns (uint) {
        return _modifySignersInfos.length;
    }

    function getSingleModifySignersProposal(uint index) external view returns (ModifySignersInfo memory) {
        require(index < _modifySignersInfos.length, "Invalid index");
        return _modifySignersInfos[index];
    }

    function getOuterProposalCount() external view returns (uint) {
        return _outerProposalInfos.length;
    }

    function getSingleOuterProposal(uint index) external view returns (OuterProposalInfo memory) {
        require(index < _outerProposalInfos.length, "Invalid index");
        return _outerProposalInfos[index];
    }

    function canVote(address voter, uint proposalId) validProposalId(proposalId) external view returns (bool, string memory) {
        return _canVote(voter, proposalId);
    }

    function canExecute(uint proposalId) validProposalId(proposalId) external view returns (bool, string memory) {
        return _canExecute(proposalId);
    }

    function getVotingThreshold() external view returns (uint) {
        return _votingThreshold;
    }

    modifier senderIsSigner() {
        require(_isSigner[_msgSender()], "Sender is not signer");
        _;
    }

    modifier isValidSignerCount(uint voteThreshold, uint signerCount) {
        require(signerCount > 0, "At least one signer required");
        require(voteThreshold > 0 && voteThreshold <= signerCount, "Invalid voteThreshold");
        _;
    }

    modifier validProposalId(uint proposalId) {
        require(proposalId < _proposals.length, "Invalid proposalId");
        _;
    }

    function _propose(proposolCategory category, uint subIndex, string calldata text) private {
        _proposals.push();
        uint proposalId = _proposals.length - 1;
        address proposer = _msgSender();
        ProposalInfo storage info = _proposals[proposalId].info;
        info.category = category;
        info.proposer = proposer;
        info.subIndex = subIndex;
        info.text = text;
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
        executionResult result = executionResult.succeeded;
        if (status.votersCon.length > _votingThreshold) {
            info.vetoed = true;
            result = executionResult.failed;
        } else {
            if (info.category == proposolCategory.modifySigners) {
                ModifySignersInfo storage m = _modifySignersInfos[info.subIndex];
                for (uint i = 0; i < _signers.length; i++) {
                    delete _isSigner[_signers[i]];
                }
                _signers = m.newSigners;
                for (uint i = 0; i < _signers.length; i++) {
                    _isSigner[_signers[i]] = true;
                }
                _votingThreshold = m.newVotingThreshold;
                emit ModifySignersExecuted(_msgSender(), proposalId, result);
            } else if (info.category == proposolCategory.outerProposal) {
                OuterProposalInfo storage m = _outerProposalInfos[info.subIndex];
                (bool success, bytes memory output) = m.target.call{value: msg.value}(m.code);
                emit OuterProposalExecuted(_msgSender(), proposalId, result, success, output);
            } else revert("Invalid category");
        }
    }

    function _canVote(address voter, uint proposalId) private view returns (bool, string memory) {
        if (!_isSigner[voter]) return (false, "Sender is not signer");
        if (hasVoted(voter,proposalId)) return (false, "Already voted");
        else return (true, "");
    }

    function _canExecute(uint proposalId) private view returns (bool, string memory) {
        Proposal storage p = _proposals[proposalId];
        if (p.info.executed) return (false, "Already executed");
        VotingStatusInfo storage info = p.status.info;
        if (info.votersPro.length < _votingThreshold && info.votersPro.length < _votingThreshold) return (false, "Not enough votes");
        else return (true, "");
    }
}