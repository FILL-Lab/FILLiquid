// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Claim is Context {

    // the actions that can be claimed
    enum Action {
        Unknown,
        FigBalance,             // 1
        FitGovernance,          // 2
        DiscordPharse2,         // 3
        DiscordLevel5,          // 4
        MinerBorrow,            // 5
        MinerPayback,           // 6
        MinerPaybackTwice,      // 7
        ActionEnd               // 8 
    }

    address private _owner;
    ERC20 private _token;

    mapping (Action => uint) private _supplys;                              // mapping action to the supply
    mapping (Action => bytes32) private _merkleRoots;                       // mapping action to the merkle root
    mapping (address => mapping (Action => bool)) private _claimeds;        // mapping address to the claim status
    mapping (address => mapping (Action => uint)) private _withdrawns;      // mapping address to the withdraw status
    mapping (Action => uint) private _stats;                                // mapping action to the number of users

    // the supplys of the claimable actions
    uint constant SUPPLY_UNIT = 10000 * 1e18;
    uint constant FIG_BALANCE_SUPPLY = 500 * SUPPLY_UNIT;
    uint constant FIT_GOVERNANCE_SUPPLY = 60 * SUPPLY_UNIT;
    uint constant DISCORD_PHARSE2_SUPPLY = 90 * SUPPLY_UNIT;
    uint constant DISCORD_LEVEL5_SUPPLY = 150 * SUPPLY_UNIT;
    uint constant MINER_BORROW_SUPPLY = 100 * SUPPLY_UNIT;
    uint constant MINER_PAYBACK_SUPPLY = 60 * SUPPLY_UNIT;
    uint constant MINER_PAYBACK_TWICE_SUPPLY = 40 * SUPPLY_UNIT;

    // airdrop only lasted for 1000 blocks, after that, the actions will be expired
    uint _startBlock = 0;
    uint _endBlock = 0;
    uint constant MONTH_IN_SECONDS = 30 * 24 * 60 * 60;
    uint constant BLOCK_SECONDS = 30;
    uint constant RELEASE_LAST_TIME = 6 * MONTH_IN_SECONDS / BLOCK_SECONDS; // 6 months

    // the number of actions
    uint private CLAIMABLE_ACTIONS = uint(Action.ActionEnd) - 1;

    // the data structure of the claim request
    struct claimRequestData {
        Action action;
        bytes32[][] proofs;
        bytes32[] leafs;
    }
    struct withdrawData {
        Action action;
        uint withdrawn;         // already withdrawn
        uint canWithdraw;       // can withdraw, which equals to the total / userCnt * (block.number - _startBlock) / RELEASE_LAST_TIME - withdrawn
    }

    // the supplys of the claimable actions
    event Claimed(address indexed account, uint amount);
    event Withdrawn(address indexed account, uint total, uint amount);

    constructor(address token) {
        _owner = msg.sender;
        _token = ERC20(token);

        // setting up the time
        _startBlock = block.number;
        _endBlock = _startBlock + RELEASE_LAST_TIME;

        // setting up the supplys
        _supplys[Action.FigBalance] = FIG_BALANCE_SUPPLY;
        _supplys[Action.FitGovernance] = FIT_GOVERNANCE_SUPPLY;
        _supplys[Action.DiscordPharse2] = DISCORD_PHARSE2_SUPPLY;
        _supplys[Action.DiscordLevel5] = DISCORD_LEVEL5_SUPPLY;
        _supplys[Action.MinerBorrow] = MINER_BORROW_SUPPLY;
        _supplys[Action.MinerPayback] = MINER_PAYBACK_SUPPLY;
        _supplys[Action.MinerPaybackTwice] = MINER_PAYBACK_TWICE_SUPPLY;
    }
    
    function setMerkleRoot(Action act, bytes32 root) external onlyOwner {
        _merkleRoots[act] = root;
    }

    function setUserNum(Action act, uint num) external onlyOwner {
        _stats[act] = num;
    }

    function setMerkleRootList(bytes32[] calldata roots) equal(roots.length, CLAIMABLE_ACTIONS) external onlyOwner {
        for (uint i = 0; i < roots.length; i++) {
            _merkleRoots[Action(i+1)] = roots[i]; // first action is unknwon
        }
    }

    function setUserNumList(uint[] calldata nums) equal(nums.length, CLAIMABLE_ACTIONS) external onlyOwner {
        for (uint i = 0; i < nums.length; i++) {
            _stats[Action(i+1)] = nums[i]; // first action is unknwon
        }
    }

    function claim(claimRequestData[] request) external payable returns (uint) {
        address account = _msgSender();
        
        actions, sum = calculateStake(account, request);
        setStakeActions(account, actions);        
        _token.transfer(account, sum);
        
        emit Claimed(account, sum);
        return sum;
    }

    function withdraw(claimRequestData[] request) expire() external payable returns (uint) {
        address account = _msgSender();
        withdrawData[] memory withdraws;
        uint sum;

        withdraws, sum = calculateBorrow(account, request);
        setWithdrawActions(account, withdraws);
        _token.transfer(account, sum);

        emit Withdrawn(account, r[0], value);
        return value;
    }

    //-------------------------------------------------------------------------
    //  View functions
    // 
    //-------------------------------------------------------------------------

    function verify(Action act, bytes32[] memory proof, bytes32 leaf) external view returns (bool) {
       return _verify(act, proof, leaf);
    }

    function getMerkleRoot(Action act) onlyOwner external view returns (bytes32) {
        return _merkleRoots[act];
    }

    function balanceOf(address account, claimRequestData[] request) external view returns (uint sum) {
       _, sum = calculateStake(account, request);
    }

    function canWithdraw(address account, claimRequestData[] request) external view returns (uint sum) {
        _, sum = calculateBorrow(account, request);
    }

    //-------------------------------------------------------------------------
    //  Help functions
    // 
    //-------------------------------------------------------------------------

    function calculateStake(address account, claimRequestData[] request) private view returns (Action[] actions, uint sum) {
        for (uint i = 0; i < request.length; i++) {
            claimRequestData memory data = request[i];
            Action act = data.action;

            if (_isStakeAction(act) == false) {
                continue;
            }
            if (_claimeds[account][act] == true) {
                continue;
            }
            if (_verify(act, data.proofs, data.leafs) == false) {
                continue;
            }
            sum += _calculate(act);
            actions.push(act);
        }
    }

    function calculateBorrow(address account, claimRequestData[] request) private view returns (withdrawData[] withdraws , uint sum) {
        for (uint i = 0; i < request.length; i++) {
            claimRequestData memory data = request[i];
            Action act = data.action;

            if (_isBorrowAction(act) == false) {
                continue;
            }
            if (_verify(act, data.proofs, data.leafs) == false) {
                continue;
            }

            uint withdrawn = _withdrawns[account][act];
            uint total = _calculate(act);
            uint current = total * (block.number - _startBlock) / RELEASE_LAST_TIME;
            require(current >= withdrawn, "Claim: no claimable token");
            uint rest = current - withdrawn;

            withdrawData wd = withdrawData(act, withdrawn, rest);
            withdraws.push(wd);
            sum += rest;
        }
    }

    function setStakeActions(address account, Action[] actions) private {
        for (uint i = 0; i < actions.length; i++) {
            Action act = actions[i];
            if (_claimeds[account][act] == true) {
                continue;
            }
            _claimeds[account][act] = true;
        }
    }

    function setWithdrawActions(address account, withdrawData[] list) private {
        for (uint i = 0; i < list.length; i++) {
            Action act = list[i].action;
            _withdrawns[account][act] += list[i].canWithdraw;
        }
    }

    function _calculate(Action act) private view returns (uint) {
        uint supply = _supplys[act];
        uint userCnt = _stats[act];
        return supply / userCnt;
    }

    function _verify(Action act, bytes32[] memory proof, bytes32 leaf) private view returns (bool) {
       bytes32 merkleRoot = _merkleRoots[act];
       return MerkleProof.verify(proof, merkleRoot, leaf);
    }

    function _checkTime() private view returns (bool) {
        return block.number <= _endBlock;
    }

    function _isStakeAction(Action act) private view returns (bool) {
        return act == Action.FigBalance || act == Action.FitGovernance || act == Action.DiscordPharse2 || act == Action.DiscordLevel5;
    }

    function _isBorrowAction(Action act) private view returns (bool) {
        return act == Action.MinerBorrow || act == Action.MinerPayback || act == Action.MinerPaybackTwice;
    }

    modifier expire() {
        require(_checkTime(), "Claim expired");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }
}