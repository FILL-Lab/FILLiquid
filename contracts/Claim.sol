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

    // borrow airdrop will last 6 months
    uint _startBlock = 0;
    uint _endBlock = 0;
    uint constant MONTH_IN_SECONDS = 30 * 86400;
    uint constant BLOCK_SECONDS = 30;
    uint constant RELEASE_LAST_TIME = 6 * MONTH_IN_SECONDS / BLOCK_SECONDS; // 6 months

    // the number of actions
    bool private _once;    // check balance only once
    uint private CLAIMABLE_ACTIONS = uint(Action.ActionEnd) - 1;
    uint _supplySum = FIG_BALANCE_SUPPLY + FIT_GOVERNANCE_SUPPLY + DISCORD_PHARSE2_SUPPLY + DISCORD_LEVEL5_SUPPLY + MINER_BORROW_SUPPLY + MINER_PAYBACK_SUPPLY + MINER_PAYBACK_TWICE_SUPPLY;

    // the data structure of the claim request
    struct Request {
        Action action;
        bytes32[] proofs;
        bytes32 leaf;
    }
   
    // the supplys of the claimable actions
    event Claimed(address indexed account, uint amount);
    event Withdrawn(address indexed account, uint amount);

    constructor(address token, bytes32[] memory merkleRoots, uint[] memory userNums) {
        _owner = msg.sender;
        _token = ERC20(token);

        // set up the merkle roots and user numbers, the first action is unkown
        require(merkleRoots.length == userNums.length && userNums.length == CLAIMABLE_ACTIONS, "Claim: invalid length");
        for (uint i = 0; i < merkleRoots.length; i++) {
            Action act = Action(i+1);
            _merkleRoots[act] = merkleRoots[i];
            _stats[act] = userNums[i];
        }

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

        _once = false;
    }
    
    // if the contract deployed with the wrong merkle root, the owner can reset it
    function setMerkleRoot(Action act, bytes32 root) external onlyOwner {
        _merkleRoots[act] = root;
    }
    // if the contract deployed with the wrong user number, the owner can reset it
    function setUserNum(Action act, uint num) external onlyOwner {
        _stats[act] = num;
    }

    function claim(Request[] calldata requests) external payable returns (uint) {
        _checkBalance();

        address account = _msgSender();
        uint sum = calculateStake(account, requests, true);
        if (sum > 0) {
            _token.transfer(account, sum);
        }
        emit Claimed(account, sum);

        return sum;
    }

    function withdraw(Request[] calldata requests) external payable returns (uint) {        
        _checkBalance();

        address account = _msgSender();
        uint sum = calculateBorrow(account, requests, true);
        if (sum > 0) {
            _token.transfer(account, sum);
        }
        emit Withdrawn(account, sum);

        return sum;
    }

    //-------------------------------------------------------------------------
    //  View functions
    // 
    //-------------------------------------------------------------------------
    function checkStake(address account, Request calldata data) public view returns (bool) {
        if (_isStakeAction(data.action) == false) {
            return false;
        }
        if (_claimeds[account][data.action] == true) {
            return false;
        }
        return _verify(data);
    }

    function checkBorrow(Request calldata data) public view returns (bool) {
        if (_isBorrowAction(data.action) == false) {
            return false;
        }
        return _verify(data);
    }

    function verify(Request calldata data) external view returns (bool) {
       return _verify(data);
    }

    function getMerkleRoot(Action act) onlyOwner external view returns (bytes32) {
        return _merkleRoots[act];
    }

    function balanceOf(address account, Request[] calldata requests) external returns (uint sum) {
       return calculateStake(account, requests, false);
    }

    function canWithdraw(address account, Request[] calldata requests) external returns (uint sum) {
        return calculateBorrow(account, requests, false);
    }

    //-------------------------------------------------------------------------
    //  Help functions
    // 
    //-------------------------------------------------------------------------
    function calculateStake(address account, Request[] calldata requests, bool shouldClaim) internal returns (uint sum) {
        bool[] memory actRecord = new bool[](uint(Action.ActionEnd));

        for (uint i = 0; i < requests.length; i++) {
            Request calldata data = requests[i];
            if (actRecord[uint(data.action)]) {
                continue;
            }
            if (checkStake(account, data)) {
                sum += _calculate(data.action);
                if (shouldClaim) {
                    _claimeds[account][data.action] = true;
                }
                actRecord[uint(data.action)] = true;
            }
        }
    }

    function calculateBorrow(address account, Request[] calldata requests, bool shouldMark) internal returns (uint sum){
        bool[] memory actRecord = new bool[](uint(Action.ActionEnd));

        for (uint i = 0; i < requests.length; i++) {
            Request calldata data = requests[i];
            if (actRecord[uint(data.action)]) {
                continue;
            }
            if (checkBorrow(data)) {
                uint withdrawn = _withdrawns[account][data.action];
                uint total = _calculate(data.action);
                uint current = total * (block.number - _startBlock) / RELEASE_LAST_TIME;
                require(current >= withdrawn, "Claim: no claimable token");
                uint rest = current - withdrawn;
                sum += rest;

                if (shouldMark) {
                    _withdrawns[account][data.action] += rest;
                }
                actRecord[uint(data.action)] = true;
            }
        }
    }

    function _calculate(Action act) private view returns (uint) {
        uint supply = _supplys[act];
        uint userCnt = _stats[act];
        return supply / userCnt;
    }

    function _verify(Request calldata data) private view returns (bool) {
       bytes32 merkleRoot = _merkleRoots[data.action];
       return MerkleProof.verify(data.proofs, merkleRoot, data.leaf);
    }

    function _isStakeAction(Action act) private pure returns (bool) {
        return act == Action.FigBalance || act == Action.FitGovernance || act == Action.DiscordPharse2 || act == Action.DiscordLevel5;
    }

    function _isBorrowAction(Action act) private pure returns (bool) {
        return act == Action.MinerBorrow || act == Action.MinerPayback || act == Action.MinerPaybackTwice;
    }

    function _checkBalance() internal {
        if (_once == false) {
            uint balance = _token.balanceOf(address(this));
            require(balance >= _supplySum, "Claim: invalid balance");
            _once = true;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }
}