// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";
import "./FLE.sol";
import "./FILL.sol";
import "./DataFetcher.sol";

contract Deployer {
    FLE private _fle;
    Validation private _validation;
    Calculation private _calculation;
    FilecoinAPI private _filecoinAPI;
    FILL private _fill;
    DataFetcher private _dataFetcher;

    event ContractPublishing (
        string name,
        address addr
    );

    constructor() payable {
        _fle = new FLE("FLEToken", "FLE");
        emit ContractPublishing("FLE", address(_fle));
        _validation = new Validation();
        emit ContractPublishing("Validation", address(_validation));
        _calculation = new Calculation();
        emit ContractPublishing("Calculation", address(_calculation));
        _filecoinAPI = new FilecoinAPI();
        emit ContractPublishing("FilecoinAPI", address(_filecoinAPI));
        _fill = new FILL(
            address(_fle),
            address(_validation),
            address(_calculation),
            address(_filecoinAPI),
            payable(msg.sender)
        );
        emit ContractPublishing("FILL", address(_fill));
        _dataFetcher = new DataFetcher(address(_fill));
        emit ContractPublishing("DataFetcher", address(_dataFetcher));
        _fle.addManager(address(_fill));
        _fill.deposit{value: msg.value}(msg.value, _fill.rateBase(), 0);
        uint fleBalance = _fill.fleBalanceOf(address(this));
        assert(fleBalance == msg.value);
        _fle.transfer(msg.sender, fleBalance);

        _fle.setOwner(msg.sender);
        _fill.setOwner(msg.sender);
    }

    function fle() external view returns (address) {
        return address(_fle);
    }

    function validation() external view returns (address) {
        return address(_validation);
    }

    function calculation() external view returns (address) {
        return address(_calculation);
    }

    function filecoinAPI() external view returns (address) {
        return address(_filecoinAPI);
    }

    function fill() external view returns (address) {
        return address(_fill);
    }

    function dataFetcher() external view returns (address) {
        return address(_dataFetcher);
    }
}