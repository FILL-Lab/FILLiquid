// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

contract ClaimData is Context {
    
    address private _owner;
    mapping (address=>bool) private _managers;

    mapping (address=>uint) private _userFigBalances;   // user balance for test1
    mapping (address=>GovernanceAction) private _govActions; // user actions for test2
    mapping (address=>StakingAction) private _stakingActions; // user actions for test3
    mapping (address=>FarmingAction) private _farmingActions; // user actions for test4
    mapping (address=>uint) private _minerActions;  // user minerBorrow for test1,test2,test3
    
    Stats private _stats;       // stats for all kinds of users number

    struct FigBalancePair {
        address user;
        uint balance;
    }

    struct Vote {
        uint proposalId;
        uint amount;
    }

    struct Deposit {
        uint amountFil;
        uint amountFit;
    }

    struct Redeem {
        uint amountFit;
        uint amountFil;
        uint fee;
    }

    struct Borrow {
        uint borrowId;
        uint minerId;
        uint amountFil;
        uint fee;
        uint interestRate;
    }

    struct Payback {
        uint payee;     // miner id payee
        uint payer;     // miner id payer
        uint principal;
        uint interest;
        uint withdrawn;
        uint mintedFIG;
    }
	
    struct Stake {
        uint stakeId;
	    uint amount;
        uint start;
        uint end;
        uint minted;
    }

    struct Interest {
        uint principal;
        uint interest;
        uint minted;
    }

    struct WithdrawFig {
        uint stakeId;
        uint amount;
    }

    struct GovernanceAction {
        mapping(address => uint[]) bonds;       // mapping bonder to amount
        mapping(address => uint[]) unbonds;     // mapping bonder to amount
        mapping(address => uint) proposals;     // mapping proposer to proposal identities
        mapping(address => Vote[]) votes;       // mapping voter to proposal identities
    }
    
    struct StakingAction {
        mapping(address => Deposit[]) deposits;
        mapping(address => Redeem[]) redeems;
        mapping(address => Borrow[]) borrows;
        mapping(address => Payback[]) paybacks;
    }

    struct FarmingAction {
        mapping(address => Stake[]) stakes;
        mapping(address => Stake[]) unstakes;
        mapping(address => Interest[]) interests;
        mapping(address => WithdrawFig[]) withdraws;
    }

    struct MinerAction {
        address family;     
        uint minerId;      
        uint minerBorrow;  
        uint minerPayback; 
    }

    struct Stats {
        uint totalFigUsers;
        uint totalFigStaking;
        uint totalFigFarming;
        uint totalFigGovernance;
        uint totalFigDiscordParse2;
        uint totalFigDiscordLevel5;
        uint totalFigMinerBorrow;
    }

    constructor() {
        _owner = _msgSender();
        _managers[_owner] = true;
    }

    function setUserFigBalance(address user, uint balance) external onlyManager {
        _setFigBalance(user, balance);
    }

    function setBatchUserFigBalances(FigBalancePair[] memory pairs) external onlyManager {
        for (uint i = 0; i < pairs.length; i++) {
            _setFigBalance(pairs[i].user, pairs[i].balance);
        }
    }

    function setUserAction(address user, UserAction memory action) external onlyManager {
        userActions[_user] = _action;
    }

    function setMinerAction(address _user, uint _minerId, uint _minerBorrow, uint _minerPayback) external onlyManager {
        minerActions[_user] = _minerBorrow;
    }

    function _setFigBalance(address user, uint balance) internal {
        require(balance > 0, "Invalid balance"); 
        
        if (_userFigBalances[user] == 0) {
            _userFigBalances[user] = balance;
            _stats.totalFigUsers += 1;
        } else {
            _userFigBalances[user] = balance;
        }
    }

    function _setUserAction(address user, UserAction memory action) internal {
        userActions[_user] = _action;
    }

    function getUserFigBalance(address _user) external view returns (uint) {
        return userFigBalances[_user];
    }

    function getUserAction(address _user) external view returns (UserAction memory) {
        return userActions[_user];
    }
    
    function getMinerAction(address _user) external view returns (uint) {
        return minerActions[_user];
    }

    function getBatchUserFigBalances(address[] memory _users) external view returns (FigBalancePair[] memory) {
        FigBalancePair[] memory _pairs = new FigBalancePair[](_users.length);
        for (uint i = 0; i < _users.length; i++) {
            _pairs[i].user = _users[i];
            _pairs[i].balance = userFigBalances[_users[i]];
        }
        return _pairs;
    }

    function setManager(address account) external onlyOwner {
        _managers[account] = true;
    }
    
    function delManager(address account) external onlyOwner {
        delete _managers[account];
    }

    function changeOwner(address account) external onlyOwner {
        _owner = account;
    }

    function verifyManager(address account) public view returns (bool) {
        return _managers[account];
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner allowed");
        _;
    }

    modifier onlyManager() {
        require(verifyManager(_msgSender()), "Only manager allowed");
        _;
    }

}