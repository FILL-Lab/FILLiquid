// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FILTrust is ERC20 {
    address private _owner;
    mapping(address => bool) private _manageAddresses;

    constructor(string memory name, string memory symbol) ERC20(name, symbol){
        _owner = _msgSender();
        addManager(_owner);
    }

    function withdraw(address account, uint256 amount) external onlyManager {
        _transfer(account, _msgSender(), amount);
    }
    
    function mint(address account, uint256 amount) external onlyManager {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyManager {
        require(amount + 10 ** decimals() <= totalSupply(), "Burn too much");
        _burn(account, amount);
    }

    function addManager(address account) public onlyOwner {
        _manageAddresses[account] = true;
    }

    function removeManager(address account) external onlyOwner {
        delete _manageAddresses[account];
    }

    function verifyManager(address account) public view returns (bool) {
        return _manageAddresses[account];
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external returns (address) {
        _owner = new_owner;
        return _owner;
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
