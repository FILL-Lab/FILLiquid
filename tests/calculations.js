const { duration } = require("@openzeppelin/test-helpers/src/time");

const BASE_RATE = 1000000n

const REDEEM_FEE_RATE = 5000n
const BORROW_FEE_RATE = 10000n

const ONE_ETHER = BigInt(1e18)

principal = ONE_ETHER * 120000n + 40243690975934386880000n
borrowAmount = ONE_ETHER * 50000n + 101363557022570715200000n + ONE_ETHER * 140000n
durationTime = BigInt(2880 * 170) * 30n * 1n
utilized = 200000n * ONE_ETHER + 101363557022570715200000n - 150000n * ONE_ETHER + (ONE_ETHER * 120000n + 40243690975934386880000n)
liquidity = ONE_ETHER * 500000n + 101363557022570715200000n + 40243690975934386880000n - 230978520000000000000000n

function calculateInterect(principal, duration, annualRate, baseRate) {
  annualRateFloat = Number(annualRate) / Number(baseRate);
  exponent = (Number(duration) * Number(annualRateFloat)) / 31536000;
  principalInterect = BigInt(Math.floor(Math.exp(exponent) * Number(principal)));
  interest = principalInterect - principal
  return interest
}


function getAnnualRate(liquidity, borrowd, baseRate) {
  console.log("liquidity, borrowd, baseRate: ", liquidity, borrowd, baseRate)
  u = borrowd * baseRate / liquidity
  interestRate = 10000n + (((100000n - 10000n) * baseRate / 500000n) * u) / baseRate
  // interestRate = (10000n + 180000n * u) / baseRate
  console.log("u: ", u)
  if (u > (baseRate / 2n)) {
    uFloat = Number(u) / Number(baseRate)
    base = (1 - 0.5) / (1 - 0.9)
    number = (0.6 / 0.1)
    n = Math.log(number) / Math.log(base)
    r = 0.1 * Math.pow((1 - 0.5) / (1 - uFloat), n)

    console.log("r: ", r, "n: ", n, "uFloat: ", uFloat, "base: ", base)

    interestRate = BigInt(Math.floor(r * Number(baseRate)))
  }
  return interestRate
}


function getFee(amount, rate, rateBase) {
  fee = amount * rate / rateBase
  if (amount * rate % rateBase != 0) {
    fee += 1n
  }
  fee = fee > amount ? amount : fee
  return fee
}


function getIntegralDN(total_interest, total_supply, half) {
  total_interest = Number(total_interest)
  total_supply = Number(total_supply)
  half = Number(half)

  nn = total_interest / half

  fnn = Math.pow(2, nn)
  dn = total_supply / fnn
  return dn
  // return BigInt(dn)
}


function getInterectAllocateFIG(total_interest, new_interest) {

  total_supply = BigInt(480000000e18)
  half = BigInt(900000e18)
  dnn = getIntegralDN(total_interest + new_interest, total_supply, half)
  dnn_1 = getIntegralDN(total_interest, total_supply, half)
  fig = dnn_1 - dnn
  return fig
  // return BigInt(Math.floor(fig))
}


function getInterestAllocateFIG(total_stake, interest) {
  total_supply = 480000000
  half = 12000000
  dnn = getIntegralDN(total_stake + interest, total_supply, half)
  dnn_1 = getIntegralDN(total_stake, total_supply, half)
  fig = dnn_1 - dnn
  return fig
  // return Math.floor(fig)
}

function getStakeAllocateFIG(total_stake, new_stake, duration_second) {
  total_supply = 720000000
  half = 13160609
  dnn = getIntegralDN(total_stake + new_stake, total_supply, half)
  dnn_1 = getIntegralDN(total_stake, total_supply, half)
  fig = dnn_1 - dnn
  return fig
  // return Math.floor(fig)
}

// annualRate = getAnnualRate(liquidity, utilized, BASE_RATE)
// console.log("annualRate: ", annualRate)

// principal = ONE_ETHER * 50000n + 101363557022570715200000n
// annualRate = 82000n
// durationTime = BigInt(2880 * 55) * 30n * 1n

principal = (ONE_ETHER * 120000n + 40243690975934386880000n)
annualRate = 254340n
durationTime = BigInt(2880 * 55) * 30n * 1n

interest = calculateInterect(principal, durationTime, annualRate, BASE_RATE)
principalInterect = principal + interest
console.log("principalInterect: ", principalInterect, "interest: ", interest)


borrowFee = getFee(principal, BORROW_FEE_RATE, BASE_RATE)
console.log("borrowFee: ", borrowFee)



// liquidity = BigInt(50e18) + 

// fig = getInterectAllocateFIG(0n, interest)
// console.log("fig: ", fig, "fig_human", Number(fig)/1e18)



figStake = getStakeAllocateFIG(0n, 10000n, 1)
console.log("figStake: ", fig, "figStakeHuman", fig)


// r = ONE_ETHER * 500000n * (1051200n / 2n)
// console.log("r: ", r)