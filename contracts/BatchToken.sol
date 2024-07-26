// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BatchTransfer is Context {
    
    address public nativeToken = address(0x0000000000000000000000000000000000000000);

    // ---------------------------------------------------------------------------------
    //  execute functions
    // 
    // ---------------------------------------------------------------------------------
    // before batch transfer, manager should approve enough amount to this contract
    function transfer(address asset, address[] memory recipients, uint256 amount) external payable returns (uint sum) {
        uint total = amount * recipients.length;
        ERC20 _token = ERC20(asset);
        address spender = _msgSender();

        // wont provide retrive function for native token, so the native token value should be equal to total
        if (asset == nativeToken) {
            require(msg.value == total, "Invalid amount");
        } else {
            require(_token.allowance(spender, address(this)) >= total, "Not enough allowance");
        }

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            if (asset == nativeToken) {
                payable(recipient).transfer(amount);
            } else {
                _token.transferFrom(spender, recipient, amount);
            }
            sum += amount;
        }
    }

    // ---------------------------------------------------------------------------------
    //  view functions
    // 
    // ---------------------------------------------------------------------------------
    function balances(address asset, address [] memory users) public view returns (uint[] memory result) {
        result = new uint[](users.length);
        ERC20 _token = ERC20(asset);

        for (uint256 i = 0; i < users.length; i++) {
            if (asset == nativeToken) {
                result[i] = users[i].balance;
            } else {
                result[i] = _token.balanceOf(users[i]);
            }
        }
    }
}