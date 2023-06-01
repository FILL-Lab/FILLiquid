// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import { UD60x18, ud, intoUint256 } from "@prb/math/src/UD60x18.sol";

uint256 constant FACTOR = 10 ** 18;
uint256 constant ANNUM = 31536000;

contract Calculation {
    function getCollateralizationRate(uint u, uint c_m, uint u_d, uint i_n, uint rateBase) external pure returns (uint) {
        require(u < rateBase, "Utilization rate cannot be bigger than 1.");
        if (u <= u_d) return c_m;
        uint base = (rateBase * (rateBase - u_d)) / (rateBase - u);
        uint exp = (u - u_d) * i_n / rateBase;
        return pow(base, exp, rateBase) * c_m / rateBase;
    }

    function getInterestRate(uint u, uint u_1, uint u_m, uint r_0, uint r_1, uint r_m, uint rateBase) external pure returns (uint) {
        require(u < rateBase, "Utilization rate cannot be bigger than 1.");
        if (u <= u_1) return r_0 + ((r_1 - r_0) * u) / u_1;
        (uint b, bool isPositive) = getB(u_1, u_m, r_0, r_1, r_m, rateBase);
        uint base = (rateBase * (rateBase - u_1)) / (rateBase - u);
        uint exp = getN(u_1, r_0, r_1, rateBase);
        uint multiple = 0;
        if (isPositive) multiple = r_1 * (rateBase * rateBase * rateBase + b * (u - u_1) * (u - u_1));
        else multiple = r_1 * (rateBase * rateBase * rateBase - b * (u - u_1) * (u - u_1));
        return pow(base, exp, rateBase) * multiple / (rateBase * rateBase * rateBase * rateBase);
    }

    function getExchangeRate(uint u, uint u_m, uint j_n, uint rateBase, uint fleLiquidity, uint filLiquidity) external pure returns (uint) {
        require(u < rateBase, "Utilization rate cannot be bigger than 1.");
        uint fleFil = rateBase;
        if (fleLiquidity != 0 && fleLiquidity != filLiquidity) {
            fleFil = filLiquidity * rateBase / fleLiquidity;
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
        return x.exp().intoUint256() * borrowAmount / FACTOR;
    }

    function getB(uint u_1, uint u_m, uint r_0, uint r_1, uint r_m, uint rateBase) private pure returns (uint, bool) {
        uint base = (rateBase * (rateBase - u_m)) / (rateBase - u_1);
        uint exp = getN(u_1, r_0, r_1, rateBase);
        uint b1 = pow(base, exp, rateBase) * r_m * rateBase * rateBase / r_1;
        uint b2 = rateBase * rateBase * rateBase;
        uint dividend = (u_m - u_1) * (u_m - u_1);
        if (b1 > b2) return ((b1 - b2)/dividend, true);
        else return ((b2 - b1)/dividend, false);
    }

    function getN(uint u_1, uint r_0, uint r_1, uint rateBase) private pure returns (uint) {
        return ((r_1 - r_0) * (rateBase - u_1) * rateBase) / (u_1 * r_1);
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

    function toUint(UD60x18 input, uint rateBase) private pure returns (uint) {
        return input.intoUint256() / conventionFactor(rateBase);
    }

    function conventionFactor(uint rateBase) private pure returns (uint) {
        return FACTOR / rateBase;
    }
}
