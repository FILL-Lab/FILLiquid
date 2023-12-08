// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Pot is Context {
    event Transferred (
        address indexed receiver,
        uint amount
    );

    address _owner;
    ERC20 _token;
    uint private _startHeight;
    uint private _totallyReleasedHeight;

    constructor (address owner, ERC20 token, uint startHeight, uint totallyReleasedHeight) {
        _owner = owner;
        _token = token;
        _startHeight = startHeight;
        _totallyReleasedHeight = totallyReleasedHeight;
    }

    function transfer(address receiver, uint amount) external onlyOwner {
        require (amount <= canReleaseNow(), "Invalid amount");
        _token.transfer(receiver, amount);
        emit Transferred(receiver, amount);
    }

    function canRelease(uint height) public view returns (uint) {
        uint total = _token.balanceOf(address(this));
        if (_totallyReleasedHeight <= _startHeight || height >= _totallyReleasedHeight) return total;
        return (height - _startHeight) * total / (_totallyReleasedHeight - _startHeight);
    }

    function canReleaseNow() public view returns (uint) {
        return canRelease(block.number);
    }

    function encode(address receiver, uint amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", receiver, amount);
    }

    function decode(bytes calldata input) external pure returns (bytes memory selector, address receiver, uint amount) {
        selector = input[:4];
        (receiver, amount) = abi.decode(input[4:], (address, uint));
    }

    function getFactors() external view returns (address, address, uint, uint) {
        return (_owner, address(_token), _startHeight, _totallyReleasedHeight);
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }
}