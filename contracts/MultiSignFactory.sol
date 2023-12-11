// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

contract MultiSignFactory is Context {
    enum voteResult {
        passed,
        pending
    }
    struct VotingStatusInfo {
        address[] voters;
    }
    struct VotingStatus {
        VotingStatusInfo info;
        mapping(address => bool) voted;
    }
    struct ProposalInfo {
        address proposer;
        address target;
        bytes code;
        bool executed;
        string text;
    }
    struct Proposal {
        ProposalInfo info;
        VotingStatus status;
    }

    event Proposed (
        address indexed proposer,
        address indexed target,
        uint indexed proposalId,
        bytes code,
        string text
    );
    event Voted (
        address indexed voter,
        uint indexed proposalId
    );
    event Unvoted (
        address indexed voter,
        uint indexed proposalId
    );
    event Executed (
        address indexed executor,
        uint indexed proposalId,
        bool success,
        bytes output
    );
    event SignersModified (
        address[] signers,
        uint votingThreshold
    );

    Proposal[] private _proposals;
    address[] private _signers;
    mapping(address => bool) _isSigner;
    uint private _votingThreshold;

    constructor(address[] memory signers, uint votingThreshold) isValidSignerCount(votingThreshold, signers.length) {
        _signers = signers;
        for (uint i = 0; i < _signers.length; i++) {
            _isSigner[_signers[i]] = true;
        }
        _votingThreshold = votingThreshold;
    }

    function propose(address target, bytes calldata code, string calldata text) senderIsSigner external payable {
        _propose(target, code, text);
    }

    function vote(uint proposalId) senderIsSigner validProposalId(proposalId) external payable {
        (bool votable, string memory reason) = _canVote(_msgSender(), proposalId);
        require(votable, reason);
        _vote(proposalId);
    }

    function unVote(uint proposalId) senderIsSigner validProposalId(proposalId) external {
        require(hasVoted(_msgSender(), proposalId), "No voting for this proposal");
        _unVote(proposalId);
    }

    function execute(uint proposalId) senderIsSigner validProposalId(proposalId) external payable {
        (bool executable, string memory reason) = _canExecute(proposalId);
        require(executable, reason);
        _execute(proposalId);
    }

    function renewSigners(address[] calldata signers, uint votingThreshold) isValidSignerCount(votingThreshold, signers.length) senderIsSelf external {
        for (uint i = 0; i < _signers.length; i++) {
            delete _isSigner[_signers[i]];
        }
        _signers = signers;
        for (uint i = 0; i < _signers.length; i++) {
            _isSigner[_signers[i]] = true;
        }
        _votingThreshold = votingThreshold;
        emit SignersModified(signers, votingThreshold);
    }

    function encode(address[] calldata signers, uint votingThreshold) external pure returns (bytes memory) {
        return abi.encodeWithSignature("renewSigners(address[],uint256)", signers, votingThreshold);
    }

    function decode(bytes calldata input) external pure returns (bytes memory selector, address[] memory signers, uint votingThreshold) {
        selector = input[:4];
        (signers, votingThreshold) = abi.decode(input[4:], (address[], uint));
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

    function getVoteResult(uint proposalId) validProposalId(proposalId) public view returns (voteResult) {
        if (_proposals[proposalId].status.info.voters.length >= _votingThreshold) return voteResult.passed;
        else return voteResult.pending;
    }

    function getVoteStatus(uint proposalId) validProposalId(proposalId) external view returns (VotingStatusInfo memory) {
        return _proposals[proposalId].status.info;
    }

    function hasVoted(address voter, uint proposalId) validProposalId(proposalId) public view returns (bool) {
        return _proposals[proposalId].status.voted[voter];
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

    modifier senderIsSelf() {
        require(_msgSender() == address(this), "Sender is not self");
        _;
    }

    modifier isValidSignerCount(uint votingThreshold, uint signerCount) {
        require(signerCount > 0, "At least one signer required");
        require(votingThreshold > 0 && votingThreshold <= signerCount, "Invalid votingThreshold");
        _;
    }

    modifier validProposalId(uint proposalId) {
        require(proposalId < _proposals.length, "Invalid proposalId");
        _;
    }

    function _propose(address target, bytes calldata code, string calldata text) private {
        _proposals.push();
        uint proposalId = _proposals.length - 1;
        address proposer = _msgSender();
        ProposalInfo storage info = _proposals[proposalId].info;
        info.proposer = proposer;
        info.target = target;
        info.code = code;
        info.text = text;
        emit Proposed(
            proposer,
            target,
            proposalId,
            code,
            text
        );
        (bool votable,) = _canVote(proposer, proposalId);
        if (votable) _vote(proposalId);
        else if (msg.value > 0) payable(proposer).transfer(msg.value);
    }

    function _vote(uint proposalId) private {
        Proposal storage p = _proposals[proposalId];
        address voter = _msgSender();
        VotingStatus storage status = p.status;
        status.voted[voter] = true;
        status.info.voters.push(voter);
        emit Voted(voter, proposalId);
        (bool executable,) = _canExecute(proposalId);
        if (executable) _execute(proposalId);
        else if (msg.value > 0) payable(voter).transfer(msg.value);
    }

    function _unVote(uint proposalId) private {
        Proposal storage p = _proposals[proposalId];
        address voter = _msgSender();
        VotingStatus storage status = p.status;
        VotingStatusInfo storage info = status.info;
        delete status.voted[voter];
        address[] storage voters = info.voters;
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == voter) {
                if (i != voters.length - 1) {
                    voters[i] = voters[voters.length - 1];
                }
                voters.pop();
                break;
            }
        }
        emit Unvoted(voter, proposalId);
    }

    function _execute(uint proposalId) private {
        ProposalInfo storage info = _proposals[proposalId].info;
        info.executed = true;
        (bool success, bytes memory output) = info.target.call{value: msg.value}(info.code);
        emit Executed(_msgSender(), proposalId, success, output);
    }

    function _canVote(address voter, uint proposalId) private view returns (bool, string memory) {
        if (!_isSigner[voter]) return (false, "Sender is not signer");
        if (hasVoted(voter,proposalId)) return (false, "Already voted");
        else return (true, "");
    }

    function _canExecute(uint proposalId) private view returns (bool, string memory) {
        if (_proposals[proposalId].info.executed) return (false, "Already executed");
        if (getVoteResult(proposalId) == voteResult.pending) return (false, "Not enough votes");
        else return (true, "");
    }
}