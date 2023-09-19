// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { UD60x18, ud, intoUint256, convert } from "@prb/math/src/UD60x18.sol";
import {uEXP2_MAX_INPUT, uUNIT} from "@prb/math/src/ud60x18/Constants.sol";

uint256 constant ANNUM = 31536000;

contract Calculation {
    function getInterestRate(uint u, uint u_1, uint r_0, uint r_1, uint rateBase, uint n) external pure returns (uint) {
        require(u < rateBase, "Utilization rate cannot be bigger than 1.");
        if (u <= u_1) return     r_0 + ((r_1 - r_0) * u) / u_1;
        UD60x18 base = toUD60x18((rateBase * (rateBase - u_1)) / (rateBase - u), rateBase);
        UD60x18 exp = ud(n);
        return toUint(base.pow(exp), rateBase) * r_1 / rateBase;
    }

    function getN(uint u_1, uint u_m, uint r_1, uint r_m, uint rateBase) external pure returns (uint n) {
        n = ((toUD60x18Direct(r_m).log2() - toUD60x18Direct(r_1).log2()) / (toUD60x18Direct(rateBase - u_1).log2() - toUD60x18Direct(rateBase - u_m).log2())).intoUint256();
        require(n >= uUNIT, "Invalid N");
    }

    function getExchangeRate(uint u, uint u_m, uint j_n, uint rateBase, uint fleLiquidity, uint filLiquidity) external pure returns (uint) {
        require(u < rateBase, "Utilization rate cannot be bigger than 1.");
        uint fleFil = rateBase;
        if (fleLiquidity != 0 && fleLiquidity != filLiquidity) {
            fleFil = fleLiquidity * rateBase / filLiquidity;
        }
        if (u <= u_m) return fleFil;
        uint base = (rateBase * (rateBase - u_m)) / (rateBase - u);
        uint exp = (u - u_m) * j_n / rateBase;
        uint m_u = pow(base, exp, rateBase);
        return m_u * fleFil / rateBase;
    }

    function getPaybackAmount(uint borrowAmount, uint borrowPeriod, uint annualRate, uint rateBase) external pure returns (uint) {
        if (borrowPeriod == 0 || borrowAmount == 0) return borrowAmount;
        UD60x18 x = ud(borrowPeriod * annualRate * conventionFactor(rateBase) / ANNUM);
        return x.exp().intoUint256() * borrowAmount / uUNIT;
    }

    function getMinted(uint current, uint amount, uint n, uint total, uint lastAccumulated) external pure returns(uint, uint) {
        uint exp = (current + amount) * uUNIT / n;
        uint currentAccumulated = total;
        if (exp <= uEXP2_MAX_INPUT) currentAccumulated -= total * uUNIT / ud(exp).exp2().intoUint256();
        if (lastAccumulated < currentAccumulated) return (currentAccumulated - lastAccumulated, currentAccumulated);
        else return (0, lastAccumulated);
    }

    function pow(uint base, uint exp, uint rateBase) private pure returns (uint) {
        UD60x18 convertedBase = toUD60x18(base, rateBase);
        UD60x18 convertedExp = toUD60x18(exp, rateBase);
        return toUint(convertedBase.pow(convertedExp), rateBase);
    }

    function expo(uint x, uint rateBase) private pure returns (uint) {
        return toUint(toUD60x18(x, rateBase).exp(), rateBase);
    }

    function toUD60x18(uint input, uint rateBase) private pure returns (UD60x18){
        return ud(input * conventionFactor(rateBase));
    }

    function toUD60x18Direct(uint input) private pure returns (UD60x18){
        return ud(input * uUNIT);
    }

    function toUint(UD60x18 input, uint rateBase) private pure returns (uint) {
        return input.intoUint256() / conventionFactor(rateBase);
    }

    function conventionFactor(uint rateBase) private pure returns (uint) {
        return uUNIT / rateBase;
    }
}
