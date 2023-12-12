// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Pot is Context {
    event Transferred (
        address indexed receiver,
        uint amount
    );
    event OwnerChanged (
        address indexed owner
    );

    address _owner;
    ERC20 _token;
    uint private _initialAmount;
    uint private _startHeight;
    uint private _totallyReleasedHeight;

    constructor (address owner, ERC20 token, uint initialAmount, uint startHeight, uint totallyReleasedHeight) {
        _owner = owner;
        _token = token;
        _initialAmount = initialAmount;
        _startHeight = startHeight;
        _totallyReleasedHeight = totallyReleasedHeight;
    }

    function transfer(address receiver, uint amount) external onlyOwner {
        require (amount <= canReleaseNow(), "Invalid amount");
        _token.transfer(receiver, amount);
        emit Transferred(receiver, amount);
    }

    function changeOwner(address new_owner) external onlyOwner {
        _owner = new_owner;
        emit OwnerChanged(_owner);
    }

    function getLocked(uint height) public view returns (uint) {
        if (_totallyReleasedHeight <= _startHeight || height >= _totallyReleasedHeight) return 0;
        else if (height <= _startHeight) return _initialAmount;
        else return (_totallyReleasedHeight - height) * _initialAmount / (_totallyReleasedHeight - _startHeight);
    }

    function getLockedNow() external view returns (uint) {
        return getLocked(block.number);
    }

    function canRelease(uint height) public view returns (uint) {
        uint balance = _token.balanceOf(address(this));
        uint locked = getLocked(height);
        if (balance > locked) return balance - locked;
        else return 0;
    }

    function canReleaseNow() public view returns (uint) {
        return canRelease(block.number);
    }

    function getFactors() external view returns (address, address, uint, uint, uint) {
        return (_owner, address(_token), _initialAmount, _startHeight, _totallyReleasedHeight);
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }
}