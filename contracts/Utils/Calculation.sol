// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { UD60x18, ud, intoUint256, convert } from "@prb/math/src/UD60x18.sol";
import { uEXP2_MAX_INPUT, uUNIT } from "@prb/math/src/ud60x18/Constants.sol";

uint256 constant ANNUM = 31536000;
uint256 constant BASE = 1e18;

contract Calculation {
    function getInterestRate(uint u, uint u_1, uint r_0, uint r_1, uint rateBase, uint n) external pure returns (uint) {
        require(u < rateBase, "Utilization rate cannot be bigger than 1");
        if (u <= u_1) return r_0 + ((r_1 - r_0) * u) / u_1;
        UD60x18 base = toUD60x18((rateBase * (rateBase - u_1)) / (rateBase - u), rateBase);
        UD60x18 exp = ud(n);
        return toUint(base.pow(exp), rateBase) * r_1 / rateBase;
    }

    function getN(uint u_1, uint u_m, uint r_1, uint r_m, uint rateBase) external pure returns (uint n) {
        n = ((toUD60x18Direct(r_m).log2() - toUD60x18Direct(r_1).log2()) / (toUD60x18Direct(rateBase - u_1).log2() - toUD60x18Direct(rateBase - u_m).log2())).intoUint256();
        require(n >= uUNIT, "Invalid N");
    }

    function getExchangeRate(uint u, uint u_m, uint rateBase, uint fitLiquidity, uint filLiquidity) external pure returns (uint) {
        require(u <= rateBase, "Utilization rate cannot be bigger than 1");
        uint filFit = rateBase;
        if (fitLiquidity != 0 && fitLiquidity != filLiquidity) {
            filFit = filLiquidity * rateBase / fitLiquidity;
        }
        if (u <= u_m) return filFit;
        return 2 * (rateBase - u) * filFit / rateBase;
    }

    function getFitByDeposit(uint amountFil, uint u_m, uint rateBase, uint fitTotalSupply, uint filLiquidity, uint utilizedLiquidity) external pure returns (uint) {
        require(utilizedLiquidity <= filLiquidity, "Utilization rate cannot be bigger than 1");
        if (amountFil == 0) return 0;
        if (fitTotalSupply == 0) return amountFil;
        if (utilizedLiquidity * rateBase <= u_m * filLiquidity) return (fitTotalSupply * amountFil) / filLiquidity;

        uint amountFilLeft = amountFil;
        uint amountFit = 0;
        uint[2] memory amountFilCurved = divideWithUpperRound(rateBase * utilizedLiquidity, u_m);
        amountFilCurved[0] -= filLiquidity;
        amountFilCurved[1] -= filLiquidity;
        if (amountFilCurved[1] > amountFil) {
            amountFilCurved[0] = amountFil;
            amountFilCurved[1] = amountFil;
        }
        amountFilLeft -= amountFilCurved[1];
        amountFit += ud((filLiquidity + amountFilCurved[0] - utilizedLiquidity) * uUNIT / (filLiquidity - utilizedLiquidity)).sqrt().unwrap() * fitTotalSupply / uUNIT - fitTotalSupply;
        if (amountFilLeft != 0) {
            amountFit += ((fitTotalSupply + amountFit) * amountFilLeft) / (filLiquidity + amountFilCurved[1]);
        }
        return amountFit;
    }

    function getFilByRedeem(uint amountFit, uint u_m, uint rateBase, uint fitTotalSupply, uint filLiquidity, uint utilizedLiquidity) external pure returns (uint) {
        require(utilizedLiquidity <= filLiquidity, "Utilization rate cannot be bigger than 1");
        require(amountFit < fitTotalSupply, "Invalid FIT amount");
        if (amountFit == 0) return 0;
        uint amountFitLeft = amountFit;
        uint amountFil = 0;
        if (filLiquidity * u_m > utilizedLiquidity * rateBase) {
            amountFil = (amountFit * filLiquidity) / fitTotalSupply;
            uint amountFilLeft = filLiquidity - utilizedLiquidity * rateBase / u_m;
            if (amountFil <= amountFilLeft) return amountFil;
            else {
                amountFil = amountFilLeft;
                uint fitExhausted = divideWithUpperRound(amountFilLeft * fitTotalSupply, filLiquidity)[1];
                if (amountFitLeft > fitExhausted) amountFitLeft -= fitExhausted;
                else return amountFil;
            }
        }
        uint theta = amountFitLeft * BASE / (fitTotalSupply - amountFit + amountFitLeft);
        amountFil += theta * (2 * BASE - theta) * (filLiquidity - amountFil - utilizedLiquidity) / (BASE * BASE);
        return amountFil;
    }

    function getPaybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate, uint rateBase) external pure returns (uint) {
        if (borrowPeriod == 0 || borrowAmount == 0) return borrowAmount;
        UD60x18 x = ud(borrowPeriod * annualRate * conversionFactor(rateBase) / ANNUM);
        return x.exp().intoUint256() * borrowAmount / uUNIT;
    }

    function getMinted(uint current, uint amount, uint n, uint total, uint lastAccumulated) external pure returns(uint, uint) {
        uint exp = (current + amount) * uUNIT / n;
        uint currentAccumulated = total;
        if (exp <= uEXP2_MAX_INPUT) currentAccumulated -= total * uUNIT / ud(exp).exp2().intoUint256();
        if (lastAccumulated < currentAccumulated) return (currentAccumulated - lastAccumulated, currentAccumulated);
        else return (0, lastAccumulated);
    }

    function toUD60x18(uint input, uint rateBase) private pure returns (UD60x18){
        return ud(input * conversionFactor(rateBase));
    }

    function toUD60x18Direct(uint input) private pure returns (UD60x18){
        return ud(input * uUNIT);
    }

    function toUint(UD60x18 input, uint rateBase) private pure returns (uint) {
        return input.intoUint256() / conversionFactor(rateBase);
    }

    function conversionFactor(uint rateBase) private pure returns (uint) {
        return uUNIT / rateBase;
    }

    function divideWithUpperRound(uint dividend, uint divisor) private pure returns (uint[2] memory r) {
        r[0] = dividend / divisor;
        if (dividend % divisor == 0) r[1] = r[0];
        else r[1] = r[0] + 1;
    }
}
