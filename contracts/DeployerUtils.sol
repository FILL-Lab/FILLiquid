// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Validation.sol";
import "./Utils/Calculation.sol";
import "./Utils/FilecoinAPI.sol";

contract DeployerUtils {
    Validation immutable private _validation;
    Calculation immutable private _calculation;
    FilecoinAPI immutable private _filecoinAPI;

    address _deployerUtils;

    constructor(
    ) {
        _deployerUtils = msg.sender;
        _validation = new Validation();
        _calculation = new Calculation();
        _filecoinAPI = new FilecoinAPI();
    }

    function getAddrs() external view returns (
        Validation,
        Calculation,
        FilecoinAPI,
        address
    ) {
        return (
            _validation,
            _calculation,
            _filecoinAPI,
            _deployerUtils
        );
    }
}