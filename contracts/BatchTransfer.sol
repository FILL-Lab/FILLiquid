// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "filecoin-solidity-api/contracts/v0.8/utils/FilAddressIdConverter.sol";

contract BatchTransfer is Context {

    //using SafeERC20 for IERC20;

    address public immutable nativeToken = address(0x0000000000000000000000000000000000000000);

    // ---------------------------------------------------------------------------------
    //  execute functions
    // 
    // ---------------------------------------------------------------------------------
    // before batch transfer, manager should approve enough amount to this contract
    function transfer(address asset, address[] memory recipients, uint256 amount) external payable returns (uint sum) {
        uint total = amount * recipients.length;
        IERC20 _token = IERC20(asset);
        address spender = _msgSender();

        if (asset == nativeToken) {
            require(msg.value >= total, "Invalid amount");
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
        IERC20 _token = IERC20(asset);

        for (uint256 i = 0; i < users.length; i++) {
            if (asset == nativeToken) {
                result[i] = users[i].balance;
            } else {
                result[i] = _token.balanceOf(users[i]);
            }
        }
    }

    function minerBalances(uint64[] calldata minerIds) public view returns (uint sum) {
        for (uint256 i = 0; i < minerIds.length; i++) {
            sum += toAddress(minerIds[i]).balance;
        }
    }
    
    function toAddress(uint64 actorId) public view returns (address) {
        return FilAddressIdConverter.toAddress(actorId);
    }

}