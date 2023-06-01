// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FILTrust is ERC20 {
    address private _owner;
    mapping(address => bool) private manageAddresses;

    constructor(string memory name, string memory symbol) ERC20(name, symbol){
        _owner = _msgSender();
        addManager(_owner);
    }
    
    function mint(address account, uint256 amount) external isManager {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external isManager {
        _burn(account, amount);
    }

    function addManager(address account) public onlyOwner {
        manageAddresses[account] = true;
    }

    function removeManager(address account) external onlyOwner {
        delete manageAddresses[account];
    }

    function verifyManager(address account) public view returns (bool) {
        return manageAddresses[account];
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external returns (address) {
        _owner = new_owner;
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Caller is not the owner.");
        _;
    }

    modifier isManager() {
        require(verifyManager(_msgSender()), "You need to be manager.");
        _;
    }
}
