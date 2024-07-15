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

    mapping (Action => uint) private _supplys;          // mapping action to the supply
    mapping (Action => bytes32) private _merkleRoots;   // mapping action to the merkle root
    mapping (address => bool) private _claimeds;        // mapping address to the claim status
    mapping (address => uint) private _withdrawns;      // mapping address to the withdraw status
    mapping (Action => uint) private _stats;            // mapping action to the number of users

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
    uint private _startBlock = 0;
    uint private _airdropEndBlock = 0;
    uint private _releaseEndBLock = 0;
    uint constant MONTH_IN_SECONDS = 30 * 24 * 60 * 60;
    uint constant BLOCK_SECONDS = 30;
    uint constant AIRDROP_LAST_TIME = 1000;                                 // 1000 blocks
    uint constant RELEASE_LAST_TIME = 6 * MONTH_IN_SECONDS / BLOCK_SECONDS; // 6 months

    // the number of actions
    uint private CLAIMABLE_ACTIONS = uint(Action.ActionEnd) - 1;

    // the supplys of the claimable actions
    event Claimed(address indexed account, uint amount);
    event Withdrawn(address indexed account, uint total, uint amount);

    constructor(address token) {
        _owner = msg.sender;
        _token = ERC20(token);

        // setting up the time
        _startBlock = block.number;
        _airdropEndBlock = _startBlock + AIRDROP_LAST_TIME;
        _releaseEndBLock = _startBlock + RELEASE_LAST_TIME;

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

    function claim(bytes32[][] memory proofs, bytes32[] memory leafs) notExpire(false) equals(proofs.length, leafs.length, 4) external payable returns (uint) {
        address account = _msgSender();
        require(_claimeds[account] == false, "Claim: already claimed");
        require(_batchVerify(Action.FigBalance, proofs, leafs), "Claim: invalid proof");

        uint sum = calculateStake();
        require(sum > 0, "Claim: no claimable token");
        _token.transfer(account, sum);
        _claimeds[account] = true;
        
        emit Claimed(account, sum);
        return sum;
    }

    function withdraw(bytes32[][] memory proofs, bytes32[] memory leafs) notExpire(true) equals(proofs.length, leafs.length, 3) external payable returns (uint) {
        address account = _msgSender();
        require(_batchVerify(Action.MinerBorrow, proofs, leafs), "Claim: invalid proof");

        uint[3] memory r = calculateBorrow(account);
        uint value = r[2];
        require(value > 0, "Claim: no claimable token");

        _token.transfer(account, value);
        _withdrawns[account] += value;

        emit Withdrawn(account, r[0], value);
        return value;
    }

    //-------------------------------------------------------------------------
    //  View functions
    // 
    //-------------------------------------------------------------------------

    function verify(Action act, bytes32[] memory proof, bytes32 leaf) public view returns (bool) {
       return _verify(act, proof, leaf);
    }

    function getMerkleRoot(Action act) onlyOwner external view returns (bytes32) {
        return _merkleRoots[act];
    }

    function getStartEndTimes() external view returns (uint[3] memory r) {
        r[0] = _startBlock;
        r[1] = _airdropEndBlock;
        r[2] = _releaseEndBLock;
    }
    
    function balanceOf(address account, bytes32[][] memory proofs, bytes32[] memory leafs) equals(proofs.length, leafs.length, 4) external view returns (uint) {
        if (_checkTime(false) == false) {
            return 0;
        }
        if (_claimeds[account] == true) {
            return 0;
        }
        if (_batchVerify(Action.FigBalance, proofs, leafs) == false) {
            return 0;
        }
        return calculateStake();
    }

    function canWithdraw(address account, bytes32[][] memory proofs, bytes32[] memory leafs) equals(proofs.length, leafs.length, 3) external view returns (uint[3] memory r) {
        if (_checkTime(true) == false) {
            return r;
        }
        if (_batchVerify(Action.MinerBorrow, proofs, leafs) == false) {
            return r;
        }
        r = calculateBorrow(account);
    }

    //-------------------------------------------------------------------------
    //  Help functions
    // 
    //-------------------------------------------------------------------------

    function calculateStake() private view returns (uint) {
        uint sum = 0;
        sum += _calculate(Action.FigBalance);
        sum += _calculate(Action.FitGovernance);
        sum += _calculate(Action.DiscordPharse2);
        sum += _calculate(Action.DiscordLevel5);
        return sum;
    }

    function calculateBorrow(address account) private view returns (uint[3] memory r) {
        uint sum = 0;
        sum += _calculate(Action.MinerBorrow);
        sum += _calculate(Action.MinerPayback);
        sum += _calculate(Action.MinerPaybackTwice);

        uint withdrawn = _withdrawns[account];
        uint current = sum * (block.number - _startBlock) / RELEASE_LAST_TIME;
        require(current >= withdrawn, "Claim: no claimable token");

        r[0] = sum;
        r[1] = withdrawn;
        r[2] = current - withdrawn;
    }

    function _calculate(Action act) private view returns (uint) {
        uint supply = _supplys[act];
        uint userCnt = _stats[act];
        return supply / userCnt;
    }

    function _batchVerify(Action startAction, bytes32[][] memory proofs, bytes32[] memory leafs) public view returns (bool) {
        for (uint i = 0; i < leafs.length; i++) {
            Action act = Action(uint(startAction) + i);
            if (_verify(act, proofs[i], leafs[i]) == false) {
                return false;
            }
        }
        return true;
    }

    function _verify(Action act, bytes32[] memory proof, bytes32 leaf) private view returns (bool) {
       bytes32 merkleRoot = _merkleRoots[act];
       return MerkleProof.verify(proof, merkleRoot, leaf);
    }

    function _checkTime(bool isWithdraw) private view returns (bool) {
        if (isWithdraw) {
            return block.number <= _releaseEndBLock;
        } else {
            return block.number <= _airdropEndBlock;
        }
    }

    modifier notExpire(bool isWithdraw) {
        require(_checkTime(isWithdraw), "Claim expired");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }

    modifier equal(uint num1, uint num2) {
        require(num1 > 0 && num1 == num2,  "Invalid args length");
        _;
    }

    modifier equals(uint num1, uint num2, uint num3) {
        require(num1 > 0 && num1 == num2 && num3 == num1,  "Invalid args length");
        _;
    }
}