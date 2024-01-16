// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./FILLiquidLogic_BorrowPayback.sol";
import "./FILLiquidLogic_Collateralize.sol";
import "./FILLiquidLogic_DepositRedeem.sol";

contract Deployer2 {
    FILLiquidLogicDepositRedeem private _logic_deposit_redeem;
    FILLiquidLogicBorrowPayback private _logic_borrow_payback;
    FILLiquidLogicCollateralize private _logic_collateralize;
    address private _owner;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor() {
        _owner = msg.sender;
        _logic_deposit_redeem = new FILLiquidLogicDepositRedeem(address(0), payable(0));
        emit ContractPublishing("FILLiquidLogicDepositRedeem", address(_logic_deposit_redeem));
        _logic_borrow_payback = new FILLiquidLogicBorrowPayback(address(0), payable(0), address(0));
        emit ContractPublishing("FILLiquidLogicBorrowPayback", address(_logic_borrow_payback));
        _logic_collateralize = new FILLiquidLogicCollateralize(address(0), payable(0), address(0), address(0));
        emit ContractPublishing("FILLiquidLogicCollateralize", address(_logic_collateralize));
    }

    function setting(address deployer2) external {
        require (msg.sender == _owner, "only owner allowed");
        _logic_deposit_redeem.setOwner(deployer2);
        _logic_borrow_payback.setOwner(deployer2);
        _logic_collateralize.setOwner(deployer2);
    }

    function getAddrs() external view returns (FILLiquidLogicDepositRedeem, FILLiquidLogicBorrowPayback, FILLiquidLogicCollateralize, address) {
        return (
            _logic_deposit_redeem,
            _logic_borrow_payback,
            _logic_collateralize,
            _owner
        );
    }
}