// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { UD60x18, ud, intoUint256, convert } from "@prb/math/src/UD60x18.sol";
import { uEXP2_MAX_INPUT, uUNIT } from "@prb/math/src/ud60x18/Constants.sol";

interface ICalculation {
    function getInterestRate(uint u, uint u_1, uint r_0, uint r_1, uint rateBase, uint n) external pure returns (uint);

    function getN(uint u_1, uint u_m, uint r_1, uint r_m, uint rateBase) external pure returns (uint n);

    function getExchangeRate(uint u, uint u_m, uint rateBase, uint fitLiquidity, uint filLiquidity) external pure returns (uint);

    function getFitByDeposit(uint amountFil, uint u_m, uint rateBase, uint fitTotalSupply, uint filLiquidity, uint utilizedLiquidity) external pure returns (uint);

    // The white paper outlines two types of redemption mechanisms for maintaining pool liquidity liveness:
    //   - Proportional Redemption when utilizationRate is less than or equal to u_m / rateBase
    //   - Discounted Redemption when utilizationRate is greater than u_m / rateBase
    function getFilByRedeem(uint amountFit, uint u_m, uint rateBase, uint fitTotalSupply, uint filLiquidity, uint utilizedLiquidity) external pure returns (uint);

    function getPaybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate, uint rateBase) external pure returns (uint);

    function getMinted(uint current, uint amount, uint n, uint total, uint lastAccumulated) external pure returns(uint, uint);
}
