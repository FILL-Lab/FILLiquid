// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MultiSignFactory is Context, ReentrancyGuard {
    enum approveResult {
        passed,
        pending
    }
    struct ApprovalStatusInfo {
        address[] approvers;
    }
    struct ApprovalStatus {
        ApprovalStatusInfo info;
        mapping(address => bool) approved;
    }
    struct ProposalInfo {
        address proposer;
        address target;
        bytes code;
        uint value;
        bool executed;
        string text;
    }
    struct Proposal {
        ProposalInfo info;
        ApprovalStatus status;
    }

    event Proposed (
        address indexed proposer,
        address indexed target,
        uint indexed proposalId,
        bytes code,
        uint value,
        string text
    );
    event Approved (
        address indexed approver,
        uint indexed proposalId
    );
    event Unapproved (
        address indexed approver,
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
        uint approvalThreshold
    );

    Proposal[] private _proposals;
    address[] private _signers;
    mapping(address => bool) public isSigner;
    uint private _approvalThreshold;

    constructor(address[] memory signers, uint approvalThreshold) isValidSignerCount(approvalThreshold, signers.length) {
        _signers = signers;
        for (uint i = 0; i < _signers.length; i++) {
            require(!isSigner[_signers[i]], "Duplicate signers");
            isSigner[_signers[i]] = true;
        }
        _approvalThreshold = approvalThreshold;
    }

    function propose(address target, bytes calldata code, uint value, string calldata text) senderIsSigner external payable {
        _propose(target, code, value, text);
    }

    function approve(uint proposalId) senderIsSigner validProposalId(proposalId) external payable {
        (bool votable, string memory reason) = _canApprove(_msgSender(), proposalId);
        require(votable, reason);
        _approve(proposalId);
    }

    function unapprove(uint proposalId) senderIsSigner validProposalId(proposalId) external {
        require(haveApproved(_msgSender(), proposalId), "No approval for this proposal");
        _unapprove(proposalId);
    }

    function execute(uint proposalId) senderIsSigner validProposalId(proposalId) external payable {
        (bool executable, string memory reason) = _canExecute(proposalId);
        require(executable, reason);
        _execute(proposalId);
    }

    function renewSigners(address[] calldata signers, uint approvalThreshold) isValidSignerCount(approvalThreshold, signers.length) senderIsSelf external {
        for (uint i = 0; i < _signers.length; i++) {
            delete isSigner[_signers[i]];
        }
        _signers = signers;
        for (uint i = 0; i < signers.length; i++) {
            require(!isSigner[signers[i]], "Duplicate signers");
            isSigner[signers[i]] = true;
        }
        _approvalThreshold = approvalThreshold;
        emit SignersModified(signers, approvalThreshold);
    }

    function encode(address[] calldata signers, uint approvalThreshold) external pure returns (bytes memory) {
        return abi.encodeWithSignature("renewSigners(address[],uint256)", signers, approvalThreshold);
    }

    function decode(bytes calldata input) external pure returns (bytes memory selector, address[] memory signers, uint approvalThreshold) {
        selector = input[:4];
        (signers, approvalThreshold) = abi.decode(input[4:], (address[], uint));
    }

    function getProposalInfo(uint proposalId) validProposalId(proposalId) external view returns (ProposalInfo memory) {
        return _proposals[proposalId].info;
    }

    function getProposalCount() external view returns (uint) {
        return _proposals.length;
    }

    function getApproveResult(uint proposalId) validProposalId(proposalId) public view returns (approveResult) {
        if (_proposals[proposalId].status.info.approvers.length >= _approvalThreshold) return approveResult.passed;
        else return approveResult.pending;
    }

    function getApproveStatus(uint proposalId) validProposalId(proposalId) external view returns (ApprovalStatusInfo memory) {
        return _proposals[proposalId].status.info;
    }

    function haveApproved(address approver, uint proposalId) validProposalId(proposalId) public view returns (bool) {
        return _proposals[proposalId].status.approved[approver];
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

    function canApprove(address approver, uint proposalId) validProposalId(proposalId) external view returns (bool, string memory) {
        return _canApprove(approver, proposalId);
    }

    function canExecute(uint proposalId) validProposalId(proposalId) external view returns (bool, string memory) {
        return _canExecute(proposalId);
    }

    function getApprovalThreshold() external view returns (uint) {
        return _approvalThreshold;
    }

    modifier senderIsSigner() {
        require(isSigner[_msgSender()], "Sender is not signer");
        _;
    }

    modifier senderIsSelf() {
        require(_msgSender() == address(this), "Sender is not self");
        _;
    }

    modifier isValidSignerCount(uint approvalThreshold, uint signerCount) {
        require(signerCount > 0, "At least one signer required");
        require(approvalThreshold >= (signerCount + 1) / 2 && approvalThreshold <= signerCount, "Invalid approvalThreshold");
        _;
    }

    modifier validProposalId(uint proposalId) {
        require(proposalId < _proposals.length, "Invalid proposalId");
        _;
    }

    function _propose(address target, bytes calldata code, uint value, string calldata text) private {
        _proposals.push();
        uint proposalId = _proposals.length - 1;
        address proposer = _msgSender();
        ProposalInfo storage info = _proposals[proposalId].info;
        info.proposer = proposer;
        info.target = target;
        info.code = code;
        info.value = value;
        info.text = text;
        emit Proposed(
            proposer,
            target,
            proposalId,
            code,
            value,
            text
        );
        (bool votable,) = _canApprove(proposer, proposalId);
        if (votable) _approve(proposalId);
        else if (msg.value > 0) payable(proposer).transfer(msg.value);
    }

    function _approve(uint proposalId) private {
        Proposal storage p = _proposals[proposalId];
        address approver = _msgSender();
        ApprovalStatus storage status = p.status;
        status.approved[approver] = true;
        status.info.approvers.push(approver);
        emit Approved(approver, proposalId);
        (bool executable,) = _canExecute(proposalId);
        if (executable) _execute(proposalId);
        else if (msg.value > 0) payable(approver).transfer(msg.value);
    }

    function _unapprove(uint proposalId) private {
        Proposal storage p = _proposals[proposalId];
        address approver = _msgSender();
        ApprovalStatus storage status = p.status;
        ApprovalStatusInfo storage info = status.info;
        delete status.approved[approver];
        address[] storage approvers = info.approvers;
        for (uint i = 0; i < approvers.length; i++) {
            if (approvers[i] == approver) {
                if (i != approvers.length - 1) {
                    approvers[i] = approvers[approvers.length - 1];
                }
                approvers.pop();
                break;
            }
        }
        emit Unapproved(approver, proposalId);
    }

    function _execute(uint proposalId) nonReentrant private {
        require(msg.value == _proposals[proposalId].info.value, "Value not match");
        ProposalInfo storage info = _proposals[proposalId].info;
        (bool success, bytes memory output) = info.target.call{value: msg.value}(info.code);
        if (success) info.executed = true;
        emit Executed(_msgSender(), proposalId, success, output);
    }

    function _canApprove(address approver, uint proposalId) private view returns (bool, string memory) {
        if (!isSigner[approver]) return (false, "Sender is not signer");
        if (haveApproved(approver,proposalId)) return (false, "Already approved");
        else return (true, "");
    }

    function _canExecute(uint proposalId) private view returns (bool, string memory) {
        if (_proposals[proposalId].info.executed) return (false, "Already executed");
        if (getApproveResult(proposalId) == approveResult.pending) return (false, "Not enough approves");
        else return (true, "");
    }
}