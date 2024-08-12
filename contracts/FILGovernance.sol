// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FILGovernance is ERC20 {
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

    event BurnerChanged(
        address indexed account
    );

    address private _owner;
    address private _burner;
    mapping(address => bool) private _manageAddresses;

    uint constant MAX_SUPPLY = 2e9;
    uint constant MAX_LIQUID = MAX_SUPPLY * 3 / 5;
    
    constructor(string memory name, string memory symbol) ERC20(name, symbol){
        _owner = _msgSender();
        _burner = _msgSender();
        _mint(_owner, maxSupply() - maxLiquid());
    }

    function withdraw(address account, uint256 amount) external onlyManager {
        address sender = _msgSender();
        _transfer(account, sender, amount);
        emit Withdrawn(account, sender, amount);
    }
    
    function mint(address account, uint256 amount) external onlyManager {
        _mint(account, amount);
        emit Minted(account, _msgSender(), amount);
    }

    function burn(uint256 amount) external {
        address sender = _msgSender();
        _burn(sender, amount);
        emit Burnt(sender, amount);
    }

    function maxSupply() public view returns (uint) {
        return _withDecimal(MAX_SUPPLY);
    }

    function maxLiquid() public view returns (uint) {
        return _withDecimal(MAX_LIQUID);
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

    function burner() external view returns (address) {
        return _burner;
    }

    function setBurner(address new_burner) onlyOwner external returns (address) {
        require(new_burner != address(0), "Invalid burner");
        _burner = new_burner;
        emit BurnerChanged(new_burner);
        return _burner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner allowed");
        _;
    }

    modifier onlyManager() {
        require(verifyManager(_msgSender()), "Only manager allowed");
        _;
    }

    modifier onlyManagerOrBurner() {
        if (_msgSender() != _burner) {
            require(verifyManager(_msgSender()), "Only manager or burner allowed");
        }
        _;
    }

    function _withDecimal(uint tokens) private view returns (uint) {
        return tokens * 10 ** decimals();
    }

    function _afterTokenTransfer(address, address, uint256) internal override view {
        require(totalSupply() <= _withDecimal(MAX_SUPPLY), "Total supply cannot exceed max supply.");
    }
}
