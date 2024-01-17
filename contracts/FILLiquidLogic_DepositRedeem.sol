// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "./Utils/Calculation.sol";
import "./FILLiquidData.sol";
import "./FILLiquidPool.sol";
import "./FILTrust.sol";

interface FILLiquidLogicDepositRedeemInterface {
    /// @dev deposit FIL to the contract, mint FILTrust
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @return amount actual FILTrust minted
    function deposit(uint exchangeRate) external payable returns (uint amount);

    /// @dev redeem FILTrust to the contract, withdraw FIL
    /// @param amountFILTrust the amount of FILTrust user would like to redeem
    /// @param exchangeRate approximated exchange rate at the point of request
    /// @return amount actual FIL withdrawal
    /// @return fee fee deducted
    function redeem(uint amountFILTrust, uint exchangeRate) external returns (uint amount, uint fee);

    /// @dev return FIL/FILTrust exchange rate: total amount of FIL liquidity divided by total amount of FILTrust outstanding
    function exchangeRate() external view returns (uint);

    /// @dev Emitted when `account` deposits `amountFIL` and mints `amountFILTrust`
    event Deposit(address indexed account, uint amountFIL, uint amountFILTrust);

    /// @dev Emitted when `account` redeems `amountFILTrust` and withdraws `amountFIL`
    event Redeem(address indexed account, uint amountFILTrust, uint amountFIL, uint fee);
}

contract FILLiquidLogicDepositRedeem is Context, FILLiquidLogicDepositRedeemInterface {
    address private _owner;
    bool private _switch;

    //administrative factors
    FILLiquidData private _data;
    FILLiquidPool private _pool;

    constructor(address filLiquidDataAddr, address payable filLiquidPoolAddr) {
        _owner = _msgSender();
        _data = FILLiquidData(filLiquidDataAddr);
        _pool = FILLiquidPool(filLiquidPoolAddr);
        _switch = true;
    }

    function deposit(uint expectAmountFILTrust) switchOn external payable returns (uint) {
        uint amountFIL = msg.value;
        (,,,,uint minDepositAmount,,,,,) = _data.getComprehensiveFactors();
        require(amountFIL >= minDepositAmount, "Value too small");
        payable(_pool).transfer(amountFIL);
        uint amountFILTrust = getFitByDeposit(amountFIL);
        _isLower(expectAmountFILTrust, amountFILTrust);
        
        _data.recordDeposit(amountFIL, amountFILTrust);
        address sender = _msgSender();
        _data.mintFIT(sender, amountFILTrust);
        
        emit Deposit(sender, amountFIL, amountFILTrust);
        return amountFILTrust;
    }

    function redeem(uint amountFILTrust, uint expectAmountFIL) switchOn external returns (uint, uint) {
        uint amountFIL = getFilByRedeem(amountFILTrust);
        _isLower(expectAmountFIL, amountFIL);
        require(amountFIL < _data.availableFIL(), "Insufficient available FIL");

        (,uint redeemFeeRate,,,,,,,,) = _data.getComprehensiveFactors();
        uint[2] memory fees = _data.calculateFee(amountFIL, redeemFeeRate);
        _data.recordRedeem(amountFILTrust, fees[0], fees[1]);
        address sender = _msgSender();
        _data.burnFIT(sender, amountFILTrust);
        if (amountFIL > 0) _pool.send(amountFIL);
        if (fees[1] > 0) _sendToFoundation(fees[1]);
        if (fees[0] > 0) payable(sender).transfer(fees[0]);

        emit Redeem(sender, amountFILTrust, fees[0], fees[1]);
        return (fees[0], fees[1]);
    }

    function mintFIT(address tokenFILTrust, address account, uint amount) external {
        FILTrust(tokenFILTrust).mint(account, amount);
    }

    function burnFIT(address tokenFILTrust, address account, uint amount) external {
        FILTrust(tokenFILTrust).burn(account, amount);
    }

    receive() onlyPool switchOn external payable {
    }

    function exchangeRate() public view returns (uint) {
        address tokenFILTrust = _getTokenFILTrust();
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        return Calculation.getExchangeRate(_data.utilizationRate(), _data.getDepositRedeemFactors(), rateBase, FILTrust(tokenFILTrust).totalSupply(), _data.totalFILLiquidity());
    }

    function getFitByDeposit(uint amountFil) public view returns (uint) {
        address tokenFILTrust = _getTokenFILTrust();
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        return Calculation.getFitByDeposit(amountFil, _data.getDepositRedeemFactors(), rateBase, FILTrust(tokenFILTrust).totalSupply(), _data.totalFILLiquidity(), _data.utilizedLiquidity());
    }

    function getFilByRedeem(uint amountFit) public view returns (uint) {
        address tokenFILTrust = _getTokenFILTrust();
        (uint rateBase,,,,,,,,,) = _data.getComprehensiveFactors();
        return Calculation.getFilByRedeem(amountFit, _data.getDepositRedeemFactors(), rateBase, FILTrust(tokenFILTrust).totalSupply(), _data.totalFILLiquidity(), _data.utilizedLiquidity());
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function setOwner(address new_owner) onlyOwner external {
        _owner = new_owner;
    }

    function getAdministrativeFactors() external view returns (address, address) {
        return (address(_data), address(_pool));
    }

    function setAdministrativeFactors(
        address new_data,
        address payable new_pool
    ) onlyOwner external {
        _data = FILLiquidData(new_data);
        _pool = FILLiquidPool(new_pool);
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

    modifier onlyPool() {
        require(_msgSender() == address(_pool), "Not pool");
        _;
    }

    modifier switchOn() {
        require(_switch, "Switch is off");
        _;
    }

    function _sendToFoundation(uint amount) private {
        (,,,,address payable foundation,,) = _data.getAdministrativeFactors();
        foundation.transfer(amount);
    }

    function _getTokenFILTrust() private view returns (address) {
        (,,,,,address tokenFILTrust,) = _data.getAdministrativeFactors();
        return tokenFILTrust;
    }

    function _isLower(uint expect, uint realtime) private pure {
        require(expect <= realtime, "Too high");
    }
}
