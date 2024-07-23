// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BatchTransfer is Context {
    
    address private _owner;
    ERC20 private _token;
    mapping (address => bool) private _managers;

    constructor(address asset) {
        _token = ERC20(asset);
        _owner = _msgSender();
    }

    // ---------------------------------------------------------------------------------
    //  execute functions
    // 
    // ---------------------------------------------------------------------------------
    function changeOwner(address newOwner) onlyOwner() external {
        require(newOwner != address(0), "Invalid owner address");
        _owner = newOwner;
    }

    // add or delete manager
    function setManager(address manager, bool add) onlyOwner() external {
        require(manager != address(0), "Invalid manager address");
        require(manager != _owner, "Owner can not be manager");
        
        if (add) {
            require(!_managers[manager], "Manager already exists");
            _managers[manager] = true;
        } else {
            require(_managers[manager], "Manager not exists");    
            delete _managers[manager];
        }
    }

    function approve(uint amount) onlyManager() external {
        _token.approve(address(this), amount);
    }

    // before batch transfer, manager should approve enough amount to this contract
    function batchTransfer(address[] memory recipients, uint256 amount) onlyManager() external {
        for (uint256 i = 0; i < recipients.length; i++) {
            _token.transferFrom(_msgSender(), recipients[i], amount);
        }
    }

    // ---------------------------------------------------------------------------------
    //  view functions
    // 
    // ---------------------------------------------------------------------------------
    function batchBalance(address [] memory users) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            balances[i] = _token.balanceOf(users[i]);
        }
        return balances;
    }

    function getInfo() public view returns (address, address) {
        return (_owner, address(_token));
    }

    function checkManager(address manager) public view returns (bool) {
        return _managers[manager];
    }
    
    // ---------------------------------------------------------------------------------
    //  help functions
    // 
    // ---------------------------------------------------------------------------------

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner can call this function");
        _;
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Only manager can call this function");
        _;
    }
}