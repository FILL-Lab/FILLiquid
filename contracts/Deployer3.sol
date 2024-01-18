// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Validation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FILTrust.sol";
import "./FILGovernance.sol";
import "./Deployer1.sol";
import "./Deployer2.sol";
import "./FILStake.sol";
import "./Governance.sol";
import "./FILLiquidData.sol";
import "./FILLiquidPool.sol";
import "./FILLiquidLogic_BorrowPayback.sol";
import "./FILLiquidLogic_Collateralize.sol";
import "./FILLiquidLogic_DepositRedeem.sol";

contract Deployer3 {
    FILStake private _filStake;
    Governance private _governance;
    FILLiquidData private _filLiquidData;
    FILLiquidPool private _filLiquidPool;
    Deployer1 private _deployer1;
    Deployer2 private _deployer2;
    address private _owner;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor(address deployer1, address deployer2) {
        _deployer1 = Deployer1(deployer1);
        (
            ,,FILTrust _filTrust,
            FILGovernance _filGovernance,
            address _ownerDeployer1
        ) = _deployer1.getAddrs();
        _deployer2 = Deployer2(deployer2);
        (
            FILLiquidLogicDepositRedeem _logic_deposit_redeem,
            FILLiquidLogicBorrowPayback _logic_borrow_payback,
            FILLiquidLogicCollateralize _logic_collateralize,
            address _ownerDeployer2
        ) = _deployer2.getAddrs();
        require (msg.sender == _ownerDeployer1, "only owner allowed");
        require (msg.sender == _ownerDeployer2, "only owner allowed");
        _owner = msg.sender;

        _filStake = new FILStake();
        emit ContractPublishing("FILStake", address(_filStake));
        _governance = new Governance();
        emit ContractPublishing("Governance", address(_governance));

        _filLiquidData = new FILLiquidData(
            address(_logic_deposit_redeem),
            address(_logic_borrow_payback),
            address(_logic_collateralize),
            address(_governance),
            payable(msg.sender),
            address(_filTrust),
            address(_filStake)
        );
        emit ContractPublishing("FILLiquidData", address(_filLiquidData));

        _filLiquidPool = new FILLiquidPool(
            payable(_logic_deposit_redeem),
            payable(_logic_borrow_payback),
            address(_logic_collateralize)
        );
        emit ContractPublishing("FILLiquidPool", address(_filLiquidPool));

        _filStake.setContractAddrs(
            address(_logic_borrow_payback),
            address(_governance),
            address(_filTrust),
            address(_filGovernance)
        );
        _governance.setContractAddrs(
            address(_filLiquidData),
            address(_filStake),
            address(_filGovernance)
        );
    }

    function setting() external payable {
        require (msg.sender == _owner, "only owner allowed");
        (
            Validation _validation,
            FilecoinAPI _filecoinAPI,
            FILTrust _filTrust,
            FILGovernance _filGovernance,
        ) = _deployer1.getAddrs();
        (
            FILLiquidLogicDepositRedeem _logic_deposit_redeem,
            FILLiquidLogicBorrowPayback _logic_borrow_payback,
            FILLiquidLogicCollateralize _logic_collateralize,
        ) = _deployer2.getAddrs();
        _filTrust.addManager(address(_logic_deposit_redeem));
        _filTrust.addManager(address(_filStake));
        _logic_deposit_redeem.setAdministrativeFactors(address(_filLiquidData), payable(_filLiquidPool));
        _logic_borrow_payback.setAdministrativeFactors(address(_filLiquidData), payable(_filLiquidPool), address(_filecoinAPI));
        _logic_collateralize.setAdministrativeFactors(address(_filLiquidData), payable(_filLiquidPool), address(_filecoinAPI), address(_validation));
        _logic_deposit_redeem.deposit{value: msg.value}(msg.value);
        uint filTrustBalance = _filTrust.balanceOf(address(this));
        assert(filTrustBalance == msg.value);
        _filTrust.transfer(msg.sender, filTrustBalance);
        
        _filGovernance.addManager(address(_filStake));
        _filGovernance.addManager(address(_governance));

        _filTrust.setOwner(msg.sender);
        _filGovernance.setOwner(msg.sender);
        _filStake.setOwner(msg.sender);
        _governance.setOwner(msg.sender);
        _filLiquidData.setOwner(msg.sender);
        _filLiquidPool.setOwner(msg.sender);
        _logic_deposit_redeem.setOwner(msg.sender);
        _logic_borrow_payback.setOwner(msg.sender);
        _logic_collateralize.setOwner(msg.sender);
        _filGovernance.transfer(msg.sender, _filGovernance.balanceOf(address(this)));
    }

    function getAddrs() external view returns (FILStake, Governance, FILLiquidData, FILLiquidPool, Deployer1, Deployer2, address) {
        return (
            _filStake,
            _governance,
            _filLiquidData,
            _filLiquidPool,
            _deployer1,
            _deployer2,
            _owner
        );
    }
}