// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BatchTransfer {
    IERC20 public token;

    address private _owner;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        _owner = msg.sender;
    }

    function setOwner(address owner) public {
        require(msg.sender == _owner, "SetOwner: Only owner can call this function");
        _owner = owner;
    }

    function setToken(address tokenAddress) public {
        require(msg.sender == _owner, "SetToken: Only owner can call this function");
        token = IERC20(tokenAddress);
    }

    function batchTransfer(address[] memory recipients, uint256 amount) public {
        for (uint256 i = 0; i < recipients.length; i++) {
            token.transferFrom(msg.sender, recipients[i], amount);
        }
    }

    function batchBalance(address [] memory users) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            balances[i] = token.balanceOf(users[i]);
        }
        return balances;
    }
}