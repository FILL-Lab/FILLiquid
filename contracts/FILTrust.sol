// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FILTrust is ERC20 {
    event Withdrawn(
        address indexed account,
        address indexed sender,
        uint256 amount
    );

    event Minted(
        address indexed account,
        address indexed sender,
        uint256 amount
    );

    event Burnt(
        address indexed account,
        address indexed sender,
        uint256 amount
    );

    event ManagerAdded(
        address indexed account
    );

    event ManagerRemoved(
        address indexed account
    );

    event OwnerChanged(
        address indexed account
    );

    address private _owner;
    mapping(address => bool) private _manageAddresses;
    mapping(address => uint) public lastMintHeight;

    uint constant MIN_LOCKING_PERIOD = 2880; // 1 day

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _owner = _msgSender();
    }

    function withdraw(address account, uint256 amount) external onlyManager {
        address sender = _msgSender();
        _transfer(account, sender, amount);
        emit Withdrawn(account, sender, amount);
    }
    
    function mint(address account, uint256 amount) external onlyManager {
        lastMintHeight[account] = block.number;
        _mint(account, amount);
        emit Minted(account, _msgSender(), amount);
    }

    function burn(address account, uint256 amount) external onlyManager {
        require(amount + 10 ** decimals() <= totalSupply(), "Burn too much");
        _burn(account, amount);
        emit Burnt(account, _msgSender(), amount);
    }

    function addManager(address account) public onlyOwner {
        _manageAddresses[account] = true;
        emit ManagerAdded(account);
    }

    function removeManager(address account) external onlyOwner {
        delete _manageAddresses[account];
        emit ManagerRemoved(account);
    }

    function verifyManager(address account) public view returns (bool) {
        return _manageAddresses[account];
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external returns (address) {
        require(new_owner != address(0), "Invalid owner");
        _owner = new_owner;
        emit OwnerChanged(new_owner);
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

    function _beforeTokenTransfer(address from, address to, uint) internal view {
        require(_manageAddresses[to] || lastMintHeight[from] + MIN_LOCKING_PERIOD <= block.number, "Just minted");
    }
}
