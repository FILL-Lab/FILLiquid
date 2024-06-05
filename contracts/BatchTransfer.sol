// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BatchTransfer {
    IERC20 public token;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }

    function batchTransfer(address[] memory recipients, uint256 amount) public {
        for (uint256 i = 0; i < recipients.length; i++) {
            token.transferFrom(msg.sender, recipients[i], amount);
        }
    }
}