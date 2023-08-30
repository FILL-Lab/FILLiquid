// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FILGovernance is ERC20 {
    address private _owner;
    mapping(address => bool) private _manageAddresses;

    uint constant MAX_SUPPLY = 2e9;
    uint constant MAX_LIQUID = MAX_SUPPLY * 3 / 5;
    
    constructor(string memory name, string memory symbol) ERC20(name, symbol){
        _owner = _msgSender();
        addManager(_owner);
        _mint(_owner, maxSupply() - maxLiquid());
    }

    function withdraw(address account, uint256 amount) external onlyManager {
        _transfer(account, _msgSender(), amount);
    }
    
    function mint(address account, uint256 amount) external onlyManager {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyManager {
        _burn(account, amount);
    }

    function maxSupply() public view returns (uint) {
        return _withDecimal(MAX_SUPPLY);
    }

    function maxLiquid() public view returns (uint) {
        return _withDecimal(MAX_LIQUID);
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

    function _withDecimal(uint tokens) private view returns (uint) {
        return tokens * 10 ** decimals();
    }

    function _afterTokenTransfer(address, address, uint256) internal override view {
        require(totalSupply() <= _withDecimal(MAX_SUPPLY), "Total supply cannot exceed max supply.");
    }
}
