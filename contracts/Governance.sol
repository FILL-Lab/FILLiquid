// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./FILLiquid.sol";
import "./FITStake.sol";
import "./FILGovernance.sol";

contract Governance is Context {
    enum proposalCategory {
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
        proposalCategory category;
        uint start;
        uint deadline;
        uint deposited;
        uint discussionIndex;
        bool executed;
        voteResult result;
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
    struct BondedAmount {
        uint amount;
        bool initialized;
    }
    event Proposed (
        address indexed proposer,
        uint indexed proposalId,
        uint indexed discussionIndex,
        proposalCategory category,
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
    event FactorsChanged(
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
    );
    event ContractAddrsChanged(
        address new_filLiquid,
        address new_fitStake,
        address new_tokenFILGovernance
    );
    event OwnerChanged(
        address indexed account
    );

    mapping(address => uint) public bondedAmount;
    mapping(uint => BondedAmount) public totalBondedAmounts;
    Proposal[] private _proposals;
    uint private _numberOfBonders;
    uint private _totalBondedAmount;
    uint private _firstActiveProposalId;  // the oldest proposal still in voting phase
    uint private _rateBase;
    uint private _minYes;
    uint private _maxNo;
    uint private _maxNoWithVeto;
    uint private _quorum;
    uint private _liquidate;
    uint private _depositRatioThreshold;
    uint private _depositAmountThreshold;
    uint private _voteThreshold;
    uint private _votingPeriod;
    uint private _executionPeriod;
    uint private _maxActiveProposals;
    address private _owner;

    FILLiquid private _filLiquid;
    FITStake private _fitStake;
    FILGovernance private _tokenFILGovernance;

    uint constant DEFAULT_RATEBASE = 1000000;
    uint constant DEFAULT_MIN_YES = 500000;
    uint constant DEFAULT_MAX_NO = 333333;
    uint constant DEFAULT_MAX_NO_WITH_VETO = 333333;
    uint constant DEFAULT_QUORUM = 400000;
    uint constant DEFAULT_LIQUIDATE = 200000;
    uint constant DEFAULT_DEPOSIT_RATIO_THRESHOLD = 10;    // 0.001% (10/1000000)
    uint constant DEFAULT_DEPOSIT_AMOUNT_THRESHOLD = 1e22;  // 10000FIG 
    uint constant DEFAULT_VOTE_THRESHOLD = 1e19;
    uint constant DEFAULT_VOTING_PERIOD = 40320; // 14 days
    uint constant DEFAULT_EXECUTION_PERIOD = 20160; // 7 days
    uint constant DEFAULT_GRID = 2880; // 1 days
    uint constant DEFAULT_MAX_ACTIVE_PROPOSAL = 1000;
    uint constant MAX_TEXT_LENGTH = 5000;

    constructor() {
        _owner = _msgSender();
        _rateBase = DEFAULT_RATEBASE;
        _minYes = DEFAULT_MIN_YES;
        _maxNo = DEFAULT_MAX_NO;
        _maxNoWithVeto = DEFAULT_MAX_NO_WITH_VETO;
        _quorum = DEFAULT_QUORUM;
        _liquidate = DEFAULT_LIQUIDATE;
        _depositRatioThreshold = DEFAULT_DEPOSIT_RATIO_THRESHOLD;
        _depositAmountThreshold = DEFAULT_DEPOSIT_AMOUNT_THRESHOLD;
        _voteThreshold = DEFAULT_VOTE_THRESHOLD;
        _votingPeriod = DEFAULT_VOTING_PERIOD;
        _executionPeriod = DEFAULT_EXECUTION_PERIOD;
        _maxActiveProposals = DEFAULT_MAX_ACTIVE_PROPOSAL;
    }

    function bond(uint amount) external {
        address sender = _msgSender();
        _tokenFILGovernance.withdraw(sender, amount);
        if (bondedAmount[sender] == 0) _numberOfBonders++;
        bondedAmount[sender] += amount;
        _totalBondedAmount += amount;
        totalBondedAmounts[_matchGrid(block.number)] = BondedAmount(_totalBondedAmount, true);

        emit Bonded(sender, amount);
    }

    // Unbond is to withdraw FIG from the governance contract
    // Only bondedAmount[sender] - maxVote can be unbonded
    // If amount = 0, or amount > bondedAmount[sender] - maxVote, unbond the maximum possible amount
    function unbond(uint amount) external {
        address sender = _msgSender();
        (uint unbondableAmount, bool unbondable, string memory reason) = canUnbond(sender);
        require(unbondable, reason);
        if (amount == 0 || amount > unbondableAmount)
            amount = unbondableAmount;
        bondedAmount[sender] -= amount;
        _totalBondedAmount -= amount;
        totalBondedAmounts[_matchGrid(block.number)] = BondedAmount(_totalBondedAmount, true);
        if (bondedAmount[sender] == 0) _numberOfBonders--;
        _tokenFILGovernance.transfer(sender, amount);

        emit Unbonded(sender, amount);
    }

    function propose(proposalCategory category, uint discussionIndex, string calldata text, uint[] calldata values) external {
        require(bytes(text).length <= MAX_TEXT_LENGTH, "Text too long");
        (bool proposable, string memory reason) = canPropose();
        require(proposable, reason);
        _checkParameter(category, values);
        address sender = _msgSender();
        uint deposits = getDepositThreshold();
        _tokenFILGovernance.withdraw(sender, deposits);
        _proposals.push();
        totalBondedAmounts[_matchGrid(block.number)] = BondedAmount(_totalBondedAmount, true);
        ProposalInfo storage info = _proposals[_proposals.length - 1].info;
        info.category = category;
        info.start = block.number;
        info.deadline = _matchGrid(block.number + _votingPeriod);
        info.deposited = deposits;
        info.discussionIndex = discussionIndex;
        info.result = voteResult.pending;
        info.text = text;
        info.proposer = sender;
        info.values = values;

        emit Proposed(
            info.proposer,
            _proposals.length - 1,
            info.discussionIndex,
            info.category,
            info.deadline,
            info.deposited,
            info.text,
            info.values
        );
    }

    function vote(uint proposalId, voteCategory category, uint amount) validProposalId(proposalId) external {
        Proposal storage p = _proposals[proposalId];
        ProposalInfo storage info = p.info;
        VotingStatus storage status = p.status;
        address voter = _msgSender();
        Voting storage voting = status.voterVotings[voter];
        (bool votable, string memory reason) = _canVote(voter, amount, voting.amountTotal, info.deadline);
        require(votable, reason);
        VotingStatusInfo storage vInfo = status.info;
        if (voting.amountTotal == 0) vInfo.voters.push(voter);
        vInfo.amountTotal += amount;
        vInfo.amounts[uint(category)] += amount;
        voting.amountTotal += amount;
        voting.amounts[uint(category)] += amount;
        totalBondedAmounts[_matchGrid(block.number)] = BondedAmount(_totalBondedAmount, true);

        emit Voted(voter, proposalId, category, amount);
    }

    function execute(uint proposalId) validProposalId(proposalId) external {
        Proposal storage p = _proposals[proposalId];
        ProposalInfo storage info = p.info;
        (bool executable, string memory reason) = _canExecute(info.deadline, info.executed);
        require(executable, reason);
        info.executed = true;
        if (_firstActiveProposalId <= proposalId) {
            _firstActiveProposalId = proposalId + 1;
        }
        address sender = _msgSender();
        voteResult result = _voteResult(p);
        info.result = result;
        totalBondedAmounts[_matchGrid(block.number)] = BondedAmount(_totalBondedAmount, true);
        if (result == voteResult.rejectedWithVeto) {
            (uint liquidate, uint remain) = _liquidateResult(info.deposited);
            _tokenFILGovernance.transfer(sender, liquidate);
            _tokenFILGovernance.burn(remain);
        } else {
            if (result == voteResult.approved) {
                // according to the white paper, the execution can be done anytime after the voting process.
                if (info.category == proposalCategory.filLiquid) {
                    _filLiquid.setGovernanceFactors(info.values);
                } else if (info.category == proposalCategory.fitStake) {
                    _fitStake.setGovernanceFactors(info.values);
                }
            }
            if (info.deadline + _executionPeriod >= block.number) {
                _tokenFILGovernance.transfer(info.proposer, info.deposited);
            } else {
                (uint liquidate, uint remain) = _liquidateResult(info.deposited);
                _tokenFILGovernance.transfer(sender, liquidate);
                _tokenFILGovernance.transfer(info.proposer, remain);
            }
        }

        emit Executed(_msgSender(), proposalId, result);
    }

    function votingProposalSum(address bonder) public returns (uint count, uint maxVote) {
        for (uint i = renew1stActiveProposal(); i < _proposals.length; i++) {
            uint amount = _proposals[i].status.voterVotings[bonder].amountTotal;
            if (amount > 0) {
                if (amount > maxVote) maxVote = amount;
                count++;
            }
        }
    }

    function renew1stActiveProposal() public returns (uint i) {
        for (i = _firstActiveProposalId; i < _proposals.length; i++) {
            if (_proposals[i].info.deadline >= block.number) break;
        }
        _firstActiveProposalId = i;
    }

    function votedForProposal(address voter, uint proposalId) validProposalId(proposalId) external view returns (Voting memory) {
        return _proposals[proposalId].status.voterVotings[voter];
    }

    function getStatus() external view returns (GovernanceInfo memory) {
        return GovernanceInfo(_numberOfBonders, _totalBondedAmount, _firstActiveProposalId);
    }

    function getProposalInfo(uint proposalId) validProposalId(proposalId) external view returns (ProposalInfo memory) {
        return _proposals[proposalId].info;
    }

    function getProposalCount() external view returns (uint) {
        return _proposals.length;
    }

    /// getDepositThreshold is to get the required amount of FIG tokens for a proposal to deposit
    /// From the white paper: 
    ///     To prevent spam, proposals must be accompanied by a deposit of FIG tokens from the proposer.
    ///     Proposals that have been deposited with at least the higher of 0.001% of FIG circulating supply or
    ///     10,000 FIG, will proceed to voting stage.
    function getDepositThreshold() public view returns (uint result) {
        result = _depositRatioThreshold * _tokenFILGovernance.totalSupply() / _rateBase;
        if (result < _depositAmountThreshold) result = _depositAmountThreshold;
    }

    function getVoteResult(uint proposalId) validProposalId(proposalId) external view returns (voteResult) {
        return _voteResult(_proposals[proposalId]);
    }

    function getVoteStatus(uint proposalId) validProposalId(proposalId) external view returns (VotingStatusInfo memory) {
        return _proposals[proposalId].status.info;
    }

    function getVoteStatusBrief(uint proposalId) validProposalId(proposalId) external view returns (Voting memory) {
        VotingStatusInfo storage info = _proposals[proposalId].status.info;
        return Voting(info.amountTotal, info.amounts);
    }

    function getProposalVoterCount(uint proposalId) validProposalId(proposalId) external view returns (uint) {
        return _proposals[proposalId].status.info.voters.length;
    }

    function getProposalVoters(uint proposalId, uint from, uint to) validProposalId(proposalId) external view returns (address[] memory result) {
        address[] storage voters = _proposals[proposalId].status.info.voters;
        require(from < to && to <= voters.length, "Invalid input");
        result = new address[](to - from);
        for (uint i = 0; i < result.length; i++) {
            result[i] = voters[from + i];
        }
    }

    function canUnbond(address sender) public returns (uint, bool, string memory) {
        if (bondedAmount[sender] == 0) return (0, false, "Not bonded");
        (, uint maxVote) = votingProposalSum(sender);
        if (bondedAmount[sender] <= maxVote) return (0, false, "all bond is on held for voting");
        else return (bondedAmount[sender] - maxVote, true, "");
    }

    function canPropose() public returns (bool, string memory) {
        if (_proposals.length - renew1stActiveProposal() < _maxActiveProposals) return (true, "");
        else return (false, "Max active proposals reached");
    }

    function canVote(uint proposalId, uint amount) external view returns (bool, string memory) {
        Proposal storage p = _proposals[proposalId];
        address voter = _msgSender();
        return _canVote(voter, amount, p.status.voterVotings[voter].amountTotal, p.info.deadline);
    }

    function canExecute(uint proposalId) external view returns (bool, string memory) {
        ProposalInfo storage info = _proposals[proposalId].info;
        return _canExecute(info.deadline, info.executed);
    }

    function getFactors() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        return (_rateBase, _minYes, _maxNo, _maxNoWithVeto, _quorum, _liquidate, _depositRatioThreshold, _depositAmountThreshold, _voteThreshold, _votingPeriod, _executionPeriod, _maxActiveProposals);
    }

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
        _depositRatioThreshold = new_depositRatioThreshold;
        _depositAmountThreshold = new_depositAmountThreshold;
        _voteThreshold = new_voteThreshold;
        _votingPeriod = new_votingPeriod;
        _executionPeriod = new_executionPeriod;
        _maxActiveProposals = new_maxActiveProposals;
        emit FactorsChanged(
            new_rateBase,
            new_minYes,
            new_maxNo,
            new_maxNoWithVeto,
            new_quorum,
            new_liquidate,
            new_depositRatioThreshold,
            new_depositAmountThreshold,
            new_voteThreshold,
            new_votingPeriod,
            new_executionPeriod,
            new_maxActiveProposals
        );
    }

    function getContractAddrs() external view returns (address, address, address) {
        return (address(_filLiquid), address(_fitStake), address(_tokenFILGovernance));
    }

    function setContractAddrs(
        address new_filLiquid,
        address new_fitStake,
        address new_tokenFILGovernance
    ) onlyOwner external {
        _filLiquid = FILLiquid(new_filLiquid);
        _fitStake = FITStake(new_fitStake);
        _tokenFILGovernance = FILGovernance(new_tokenFILGovernance);
        emit ContractAddrsChanged(new_filLiquid, new_fitStake, new_tokenFILGovernance);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external returns (address) {
        _owner = new_owner;
        emit OwnerChanged(new_owner);
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

    function _checkParameter(proposalCategory category, uint[] calldata params) private view {
        if (category == proposalCategory.filLiquid) {
            _filLiquid.checkGovernanceFactors(params);
        } else if (category == proposalCategory.fitStake) {
            _fitStake.checkGovernanceFactors(params);
        } else {
            require(params.length == 0, "Invalid input length");
        }
    }

    // _voteResult is to calculate the vote result
    // The invoker needs to make sure that the voting period is ended upon calling this function
    function _voteResult(Proposal storage proposal) private view returns (voteResult result) {
        VotingStatusInfo storage info = proposal.status.info;
        uint amountTotal = info.amountTotal;
        uint amountYes = info.amounts[uint(voteCategory.yes)];
        uint amountNo = info.amounts[uint(voteCategory.no)];
        uint amountNoWithVeto = info.amounts[uint(voteCategory.noWithVeto)];
        if (amountNoWithVeto > 0 && amountNoWithVeto * _rateBase >= amountTotal * _maxNoWithVeto) {
            result = voteResult.rejectedWithVeto;
        } else if ((amountNo + amountNoWithVeto) * _rateBase >= amountTotal * _maxNo) {
            result = voteResult.rejected;
        } else if (amountYes * _rateBase >= amountTotal * _minYes) {
            uint s = proposal.info.deadline;
            while (!totalBondedAmounts[s].initialized) {
                s -= DEFAULT_GRID;
            }
            if (amountTotal * _rateBase >= totalBondedAmounts[s].amount * _quorum) result = voteResult.approved;
            else result = voteResult.rejected;
        } else {
            result = voteResult.rejected;
        }
    }

    // function voteResult2(uint proposalId) external view returns (voteResult result) {
    //     Proposal storage proposal = _proposals[proposalId];
    //     VotingStatusInfo storage info = proposal.status.info;
    //     uint amountTotal = info.amountTotal;
    //     uint amountYes = info.amounts[uint(voteCategory.yes)];
    //     uint amountNo = info.amounts[uint(voteCategory.no)];
    //     uint amountNoWithVeto = info.amounts[uint(voteCategory.noWithVeto)];
    //     if (amountNoWithVeto > 0 && amountNoWithVeto * _rateBase >= amountTotal * _maxNoWithVeto) {
    //         result = voteResult.rejectedWithVeto;
    //     } else if ((amountNo + amountNoWithVeto) * _rateBase >= amountTotal * _maxNo) {
    //         result = voteResult.rejected;
    //     } else if (amountYes * _rateBase >= amountTotal * _minYes) {
    //         uint s = proposal.info.deadline;
    //         while (!totalBondedAmounts[s].initialized) {
    //             s -= DEFAULT_GRID;
    //         }
    //         if (amountTotal * _rateBase >= totalBondedAmounts[s].amount * _quorum) result = voteResult.approved;
    //         else result = voteResult.rejected;
    //     } else {
    //         result = voteResult.rejected;
    //     }
    // }

    function _liquidateResult(uint amount) private view returns (uint liquidate, uint remain) {
        liquidate = amount * _liquidate;
        if (liquidate % _rateBase == 0) liquidate /= _rateBase;
        else liquidate = liquidate / _rateBase + 1;
        if (liquidate > amount) liquidate = amount;
        remain = amount - liquidate;
    }

    function _canVote(address voter, uint amount, uint amountTotal, uint deadline) private view returns (bool, string memory) {
        if (amount < _voteThreshold) return (false, "Voting amount too low");
        if (deadline < block.number) return (false, "Proposal voting finished");
        if (amountTotal + amount > bondedAmount[voter]) return (false, "Bonded FIG not enough");
        else return (true, "");
    }

    function _canExecute(uint deadline, bool executed) private view returns (bool, string memory) {
        if (deadline >= block.number) return (false, "Proposal voting in progress");
        if (executed) return (false, "Already executed");
        else return (true, "");
    }

    function _matchGrid(uint height) private pure returns (uint) {
        return (height + DEFAULT_GRID - 1) / DEFAULT_GRID * DEFAULT_GRID;
    }
}
