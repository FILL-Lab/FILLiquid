// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

contract FILLiquidPool is Context {
    address private _owner;
    bool private _switch;
    address payable private _logic_deposit_redeem;
    address payable private _logic_borrow_payback;
    address private _logic_collateralize;

    constructor(address payable logic_deposit_redeem, address payable logic_borrow_payback, address logic_collateralize) {
        _owner = _msgSender();
        _logic_deposit_redeem = logic_deposit_redeem;
        _logic_borrow_payback = logic_borrow_payback;
        _logic_collateralize = logic_collateralize;
        _switch = true;
    }

    function changeBeneficiary(
        address filecoinAPI,
        uint64 minerId,
        bytes calldata beneficiary,
        uint quota,
        int64 expiration
    ) onlyLogicCollateralize switchOn external {
        _changeBeneficiary(filecoinAPI, minerId, beneficiary, quota, expiration);
    }

    function withdrawBalance(address filecoinAPI, uint64 minerId, uint withdrawnAmount) onlyLogicBorrowPayback switchOn external {
        _withdrawBalance(filecoinAPI, minerId, withdrawnAmount);
    }

    receive() onlyLogicReceiver switchOn external payable {
    }

    function send(uint amount) onlyLogicReceiver switchOn external {
        if (amount > 0) {
            _send(amount, payable(_msgSender()));
        }
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function getAdministrativeFactors() external view returns (address payable, address payable, address) {
        return (_logic_deposit_redeem, _logic_borrow_payback, _logic_collateralize);
    }

    function setAdministrativeFactors(
        address payable new_logic_deposit_redeem,
        address payable new_logic_borrow_payback,
        address new_logic_collateralize
    ) onlyOwner external {
        _logic_deposit_redeem = new_logic_deposit_redeem;
        _logic_borrow_payback = new_logic_borrow_payback;
        _logic_collateralize = new_logic_collateralize;
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

    modifier onlyLogicBorrowPayback() {
        require(_msgSender() == _logic_borrow_payback, "Not logic_borrow_payback");
        _;
    }

    modifier onlyLogicCollateralize() {
        require(_msgSender() == _logic_collateralize, "Not logic_collateralize");
        _;
    }

    modifier onlyLogicReceiver() {
        require(_msgSender() == _logic_borrow_payback || _msgSender() == _logic_deposit_redeem, "Not logic_borrow_payback or logic_deposit_redeem");
        _;
    }

    modifier switchOn() {
        require(_switch, "Switch is off");
        _;
    }

    function _send(uint amount, address payable receiver) private {
        receiver.transfer(amount);
    }

    function _changeBeneficiary(
        address filecoinAPI,
        uint64 minerId,
        bytes calldata beneficiary,
        uint quota,
        int64 expiration
    ) private {
        (bool success, ) = filecoinAPI.delegatecall(
            abi.encodeWithSignature("changeBeneficiary(uint64,bytes,uint256,int64)", minerId, beneficiary, quota, expiration)
        );
        require(success, "ChangeBeneficiary failed");
    }

    function _withdrawBalance(address filecoinAPI, uint64 minerId, uint withdrawnAmount) private {
        if (withdrawnAmount > 0) {
            (bool success, bytes memory data) = filecoinAPI.delegatecall(
                abi.encodeWithSignature("withdrawBalance(uint64,uint256)", minerId, withdrawnAmount)
            );
            require(success, "WithdrawBalance failed");
            require(uint(bytes32(data)) == withdrawnAmount, "Invalid withdrawal");
        }
    }
}
