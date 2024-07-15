// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

contract FILPot is Context {
    event Transferred (
        address indexed receiver,
        uint amount
    );
    event OwnerChanged (
        address indexed owner
    );

    address private _owner;

    constructor(address owner) {
        require(owner != address(0), "Invalid owner");
        _owner = owner;
    }

    receive() external payable {}

    function transfer(address payable receiver, uint amount) external onlyOwner {
        require (amount <= address(this).balance, "Invalid amount");
        emit Transferred(receiver, amount);
        (bool result,) = receiver.call{value: amount}("");
        require(result);
    }

    function transferAll(address payable receiver) external onlyOwner {
        uint amount = address(this).balance;
        emit Transferred(receiver, amount);
        receiver.transfer(amount);
    }

    function changeOwner(address new_owner) external onlyOwner {
        require(new_owner != address(0), "Invalid owner");
        _owner = new_owner;
        emit OwnerChanged(_owner);
    }

    function getFactors() external view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }
}
