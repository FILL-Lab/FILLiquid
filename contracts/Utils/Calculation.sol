// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { UD60x18, ud, intoUint256, convert } from "@prb/math/src/UD60x18.sol";
import { uEXP2_MAX_INPUT, uUNIT } from "@prb/math/src/ud60x18/Constants.sol";

uint256 constant ANNUM = 1051200;
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
        require(utilizedLiquidity < filLiquidity || filLiquidity == 0, "Utilization rate must be smaller than 1");
        if (amountFil == 0) return 0;
        if (fitTotalSupply == 0 || filLiquidity == 0) return amountFil;
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

    // The white paper outlines two types of redemption mechanisms for maintaining pool liquidity liveness:
    //   - Proportional Redemption when utilizationRate is less than or equal to u_m / rateBase
    //   - Discounted Redemption when utilizationRate is greater than u_m / rateBase
    function getFilByRedeem(uint amountFit, uint u_m, uint rateBase, uint fitTotalSupply, uint filLiquidity, uint utilizedLiquidity) external pure returns (uint) {
        require(utilizedLiquidity < filLiquidity, "Utilization rate must be smaller than 1");
        require(amountFit < fitTotalSupply, "Invalid FIT amount");
        if (amountFit == 0) return 0;
        uint amountFit2DiscRedeem = amountFit; 
        uint amountFil4Redeem = 0;

        // Check if Partial or complete Proportional Redemption is required.
        if (filLiquidity * u_m > utilizedLiquidity * rateBase) { 
            // The maximum FIL amount that Proportional Redemption can perform under the current conditions
            // The utilizationRate == u_m after maximum proportional redempation, i.e.
            // utilizedLiquidity / (filLiquidity - maxAmountFil4PropRedeem) = u_m / rateBase
            uint maxAmountFil4PropRedeem = filLiquidity - utilizedLiquidity * rateBase / u_m;

            uint maxAmountFit2PropRedeem = divideWithUpperRound(maxAmountFil4PropRedeem * fitTotalSupply, filLiquidity)[1];
            if (amountFit <= maxAmountFit2PropRedeem) {
                // All redemption could be proportional
                return (amountFit * filLiquidity) / fitTotalSupply;
            } else {
                // There will be both proportional and discounted redemptions
                amountFit2DiscRedeem -= maxAmountFit2PropRedeem;
                amountFil4Redeem = maxAmountFil4PropRedeem;
            }
        } 

        // Plus the amount of FIL for the discounted redemption 
        uint theta = amountFit2DiscRedeem * BASE / (fitTotalSupply - amountFit + amountFit2DiscRedeem);
        amountFil4Redeem += theta * (2 * BASE - theta) * (filLiquidity - amountFil4Redeem - utilizedLiquidity) / (BASE * BASE);
        return amountFil4Redeem;
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
