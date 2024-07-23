// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintableToken is ERC20 {
    
    address public _owner;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _owner = _msgSender();
    }

    function mint(address account, uint256 amount) onlyOwner() external {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) onlyOwner() external {
        _burn(account, amount);
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Only owner can call this function");
        _;
    }
}