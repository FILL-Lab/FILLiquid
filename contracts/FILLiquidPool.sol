// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

contract FILLiquidPool is Context {
    address private _owner;
    address payable private _logic;
    bool private _switch;

    constructor(address payable logicAddr) {
        _owner = _msgSender();
        _logic = logicAddr;
        _switch = true;
    }

    function changeBeneficiary(
        uint64 minerId,
        bytes calldata beneficiary,
        uint quota,
        int64 expiration
    ) onlyLogic switchOn external {
        _changeBeneficiary(minerId, beneficiary, quota, expiration);
    }

    function withdrawBalance(uint64 minerId, uint withdrawnAmount) onlyLogic switchOn external {
        _withdrawBalance(minerId, withdrawnAmount);
    }

    receive() onlyLogic switchOn external payable {
    }

    function send(uint amount) onlyLogic switchOn external {
        if (amount > 0) {
            _send(amount);
        }
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function getAdministrativeFactors() external view returns (address payable) {
        return _logic;
    }

    function setAdministrativeFactors(address payable new_logic) onlyOwner external {
        _logic = new_logic;
    }

    function getSwitch() external view returns (bool) {
        return _switch;
    }

    function turnSwitch(bool new_switch) onlyOwner external {
        _switch = new_switch;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Not owner");
        _;
    }

    modifier onlyLogic() {
        require(_msgSender() == _logic, "Not logic");
        _;
    }

    modifier switchOn() {
        require(_switch, "Switch is off");
        _;
    }

    function _send(uint amount) private {
        _logic.transfer(amount);
    }

    function _changeBeneficiary(
        uint64 minerId,
        bytes calldata beneficiary,
        uint quota,
        int64 expiration
    ) private {
        (bool success, ) = _logic.delegatecall(
            abi.encodeWithSignature("changeBeneficiary(uint64,(bytes),uint256,int64)", minerId, beneficiary, quota, expiration)
        );
        require(success, "ChangeBeneficiary failed");
    }

    function _withdrawBalance(uint64 minerId, uint withdrawnAmount) private {
        if (withdrawnAmount > 0) {
            (bool success, bytes memory data) = _logic.delegatecall(
                abi.encodeWithSignature("withdrawBalance(uint64,uint256)", minerId, withdrawnAmount)
            );
            require(success, "WithdrawBalance failed");
            require(uint(bytes32(data)) == withdrawnAmount, "Invalid withdrawal");
        }
    }
}
