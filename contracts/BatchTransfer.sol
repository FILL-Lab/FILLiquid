// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BatchTransfer is Context {
    
    address private _owner;
    ERC20 private _token;
    mapping (address => bool) _managers;

    constructor(address asset) {
        _token = ERC20(asset);
        _owner = _msgSender();
        _managers[_owner] = true;
    }

    // change owner
    function changeOwner(address newOwner) onlyOwner() external {
        _owner = newOwner;
    }

    // add or delete manager
    function setManager(address manager, bool status) onlyOwner() external {
        _managers[manager] = status;
    }

    // before batch transfer, manager should approve enough amount to this contract
    function batchTransfer(address[] memory recipients, uint256 amount) onlyManager() external {
        for (uint256 i = 0; i < recipients.length; i++) {
            _token.transferFrom(_msgSender(), recipients[i], amount);
        }
    }

    function batchBalance(address [] memory users) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            balances[i] = _token.balanceOf(users[i]);
        }
        return balances;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner can call this function");
        _;
    }

    modifier onlyManager() {
        require(_managers[_msgSender()], "Only manager can call this function");
        _;
    }
}