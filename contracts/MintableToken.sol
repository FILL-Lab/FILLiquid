// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
* @title {Mintable ERC20 Token}
*/
contract MintableERC20 is ERC20("fil-governance-test", "FIG"), Ownable {
    /** 
    * @dev See (ERC20 - _mint) function for details.
    *
    */
    function mint(address to, uint256 amount) external payable onlyOwner() {
        _mint(to, amount);
    }
}