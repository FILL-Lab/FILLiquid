// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Claim is Context, ReentrancyGuard {
    
    // the actions that can be claimed
    enum Action {
        Unknown,
        FigBalance,             // 1
        FitGovernance,          // 2
        DiscordPhase2,          // 3
        DiscordLevel5,          // 4
        MinerBorrow,            // 5
        MinerPayback,           // 6
        MinerBorrowTwice,       // 7
        ActionEnd               // 8 
    }

    address public immutable _reserve;     // the reserve address, the rest token will be sent to this address  
    ERC20 public immutable _token;

    mapping (Action => uint) public _supplies;                              // mapping action to the supply
    mapping (Action => bytes32) public _merkleRoots;                        // mapping action to the merkle root
    mapping (address => mapping (Action => bool)) public _claimeds;         // mapping address to the claim status
    mapping (address => mapping (Action => uint)) public _withdrawns;       // mapping address to the withdraw status
    mapping (Action => uint) public _stats;                                 // mapping action to the single user reward

    // the supplys of the claimable actions
    uint constant SUPPLY_UNIT = 10000 * 1e18;
    uint constant FIG_BALANCE_SUPPLY = 500 * SUPPLY_UNIT;
    uint constant FIT_GOVERNANCE_SUPPLY = 60 * SUPPLY_UNIT;
    uint constant DISCORD_PHASE2_SUPPLY = 90 * SUPPLY_UNIT;
    uint constant DISCORD_LEVEL5_SUPPLY = 150 * SUPPLY_UNIT;
    uint constant MINER_BORROW_SUPPLY = 100 * SUPPLY_UNIT;
    uint constant MINER_PAYBACK_SUPPLY = 60 * SUPPLY_UNIT;
    uint constant MINER_BORROW_TWICE_SUPPLY = 40 * SUPPLY_UNIT;

    // borrow airdrop will last 6 months
    uint _startBlock = 0;
    uint _releaseEndBlock = 0;
    uint _airdropEndBlock = 0;
    uint constant BLOCK_PER_MOUNTH = 30 * 86400 / 30;
    uint constant RELEASE_LAST_BLOCK = 6 * BLOCK_PER_MOUNTH;                        // 6 months
    uint constant AIRDROP_LAST_BLOCK = RELEASE_LAST_BLOCK + 6 * BLOCK_PER_MOUNTH;   // 12 months

    // the number of actions
    bool private _once;    // check balance only once
    uint private CLAIMABLE_ACTIONS = uint(Action.ActionEnd) - 1;
    uint _supplySum = FIG_BALANCE_SUPPLY + FIT_GOVERNANCE_SUPPLY + DISCORD_PHASE2_SUPPLY + DISCORD_LEVEL5_SUPPLY + MINER_BORROW_SUPPLY + MINER_PAYBACK_SUPPLY + MINER_BORROW_TWICE_SUPPLY;

    // the data structure of the claim request
    struct Request {
        Action action;
        bytes32[] proofs;
        bytes32 leaf;
    }
    struct CalculateResult {
        uint sum;           // can get at most sum token
        uint total;         // total amount
        CalculateData[] data;
    }
    struct CalculateData {
        Action action;
        uint amount;
    }

    // the supplys of the claimable actions
    event Claimed(address indexed account, uint amount);
    event Withdrawn(address indexed account, uint amount);

    constructor(address token, address reserve, bytes32[] memory merkleRoots, uint[] memory userNums) {
        _reserve = reserve;
        _token = ERC20(token);

        // set up the merkle roots and user numbers, the first action is unkown
        require(merkleRoots.length == userNums.length && userNums.length == CLAIMABLE_ACTIONS, "Claim: invalid length");
        
        // setting up the time
        _startBlock = block.number;
        _releaseEndBlock = _startBlock + RELEASE_LAST_BLOCK;
        _airdropEndBlock = _startBlock + AIRDROP_LAST_BLOCK;

        // setting up the supplys
        _supplies[Action.FigBalance] = FIG_BALANCE_SUPPLY;
        _supplies[Action.FitGovernance] = FIT_GOVERNANCE_SUPPLY;
        _supplies[Action.DiscordPhase2] = DISCORD_PHASE2_SUPPLY;
        _supplies[Action.DiscordLevel5] = DISCORD_LEVEL5_SUPPLY;
        _supplies[Action.MinerBorrow] = MINER_BORROW_SUPPLY;
        _supplies[Action.MinerPayback] = MINER_PAYBACK_SUPPLY;
        _supplies[Action.MinerBorrowTwice] = MINER_BORROW_TWICE_SUPPLY;

        // setting up merkle roots and stats
        for (uint i = 0; i < merkleRoots.length; i++) {
            Action act = Action(i+1);
            _merkleRoots[act] = merkleRoots[i];
            _stats[act] = _supplies[act] / userNums[i];
        }

        _once = false;
    }
    
    // if the contract has some token left, the owner can retrive it after the airdrop end
    // anyone can call this function
    function retrieve() external returns (uint) {
        require(block.number > _airdropEndBlock, "Claim: not reach the end block");

        uint restBalance = _token.balanceOf(address(this));
        if (restBalance > 0) {
            _token.transfer(_reserve, restBalance);
        }
        return restBalance;
    }

    // user participant governance and discord can be claimed, and user will get the reward
    function claim(Request[] calldata requests) expire nonReentrant external returns (uint) {
        _checkBalance();

        address account = _msgSender();
        CalculateResult memory r = calculateStake(account, requests);
        if (r.sum > 0) {
            _token.transfer(account, r.sum);
        }
        for (uint i = 0; i < r.data.length; i++) {
            CalculateData memory item = r.data[i];
            _claimeds[account][item.action] = true;
        }
        emit Claimed(account, r.sum);

        return r.sum;
    }

    // user borrow and payback FIL token can be withdrawn, and user will get the reward
    function withdraw(Request[] calldata requests) expire nonReentrant external returns (uint) {        
        _checkBalance();

        address account = _msgSender();
        CalculateResult memory r = calculateBorrow(account, requests);
        if (r.sum > 0) {
            _token.transfer(account, r.sum);
        }
        for (uint i = 0; i < r.data.length; i++) {
            CalculateData memory item = r.data[i];
            _withdrawns[account][item.action] += item.amount;
        }
        emit Withdrawn(account, r.sum);

        return r.sum;
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
        return _verify(account, data);
    }

    function checkBorrow(address account, Request calldata data) public view returns (bool) {
        if (_isBorrowAction(data.action) == false) {
            return false;
        }
        return _verify(account, data);
    }

    function verify(address account, Request calldata data) external view returns (bool) {
       return _verify(account, data);
    }

    function balanceOf(address account, Request[] calldata requests) public view returns (uint sum) {
        if (_checkTime()) {
            CalculateResult memory r = calculateStake(account, requests);
            sum = r.sum;
        }
    }

    function canWithdraw(address account, Request[] calldata requests) public view returns (uint sum, uint total) {
        if (_checkTime()) {
            CalculateResult memory r = calculateBorrow(account, requests);
            sum = r.sum;
            total = r.total;
        }
    }

    //-------------------------------------------------------------------------
    //  Help functions
    // 
    //-------------------------------------------------------------------------
    function calculateStake(address account, Request[] calldata requests) private view returns (CalculateResult memory r) {
        bool[] memory actDumpRecord = new bool[](uint(Action.ActionEnd));
        CalculateData[] memory list = new CalculateData[](requests.length);

        for (uint i = 0; i < requests.length; i++) {
            Request calldata data = requests[i];
            if (actDumpRecord[uint(data.action)]) {
                continue;
            }
            if (checkStake(account, data)) {
                uint amount = _calculate(data.action);
                r.sum += amount;
                list[i] = CalculateData(data.action, amount);
                actDumpRecord[uint(data.action)] = true;
            }
        }
        r.data = list;
    }

    function calculateBorrow(address account, Request[] calldata requests) private view returns (CalculateResult memory r){
        bool[] memory actDumpRecord = new bool[](uint(Action.ActionEnd));
        CalculateData[] memory list = new CalculateData[](requests.length);

        for (uint i = 0; i < requests.length; i++) {
            Request calldata data = requests[i];
            if (actDumpRecord[uint(data.action)]) {
                continue;
            }
            if (checkBorrow(account, data)) {
                uint withdrawn = _withdrawns[account][data.action];
                uint total = _calculate(data.action);
                uint height = block.number > _releaseEndBlock ? _releaseEndBlock : block.number;
                uint current = total * (height - _startBlock) / RELEASE_LAST_BLOCK;
                require(current >= withdrawn, "Claim: no claimable token");
                uint rest = current - withdrawn;
                r.sum += rest;
                r.total += total;
                list[i] = CalculateData(data.action, rest);
                actDumpRecord[uint(data.action)] = true;
            }
        }
        r.data = list;
    }

    function _calculate(Action act) private view returns (uint) {
        return _stats[act];
    }

    function _calculateLeafHash(address account) private pure returns (bytes32) {
        // Encode the address
        bytes memory encoded = abi.encode(account);

        // Perform double Keccak256 hashing
        bytes32 hash1 = keccak256(encoded);
        bytes32 hash2 = keccak256(abi.encodePacked(hash1));

        return hash2;
    }

    function _verify(address account, Request calldata data) private view returns (bool) {
        bytes32 leafHash = _calculateLeafHash(account);
        require(leafHash == data.leaf, "Claim: invalid leaf hash");

        bytes32 merkleRoot = _merkleRoots[data.action];
        return MerkleProof.verify(data.proofs, merkleRoot, data.leaf);
    }

    function _isStakeAction(Action act) private pure returns (bool) {
        return act == Action.FigBalance || act == Action.FitGovernance || act == Action.DiscordPhase2 || act == Action.DiscordLevel5;
    }

    function _isBorrowAction(Action act) private pure returns (bool) {
        return act == Action.MinerBorrow || act == Action.MinerPayback || act == Action.MinerBorrowTwice;
    }

    function _checkBalance() internal {
        if (_once == false) {
            uint balance = _token.balanceOf(address(this));
            require(balance >= _supplySum, "Claim: invalid balance");
            _once = true;
        }
    }

    function _checkTime() private view returns (bool) {
        return block.number <= _airdropEndBlock;
    }

    modifier expire() {
        require(_checkTime(), "Claim: airdrop expired");
        _;
    }
}