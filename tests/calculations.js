
const BASE_RATE = 1000000n

const REDEEM_FEE_RATE = 5000n
const BORROW_FEE_RATE = 10000n


function calculateInterect(principal, duration, annualRate, baseRate) {
  annualRateFloat = Number(annualRate) / Number(baseRate);
  exponent = (Number(duration) * Number(annualRateFloat)) / 31536000;
  principalInterect = BigInt(Math.floor(Math.exp(exponent) * Number(principal)));
  interest = principalInterect - principal
  return interest
}


function getAnnualRate(liquidity, borrowd, baseRate) {
  u = borrowd * baseRate / liquidity
  interestRate = 10000n + (((100000n - 10000n) * baseRate / 500000n) * u) / baseRate
  // interestRate = (10000n + 180000n * u) / baseRate
  if (u > (baseRate / 2n)) {
    uFloat = Number(u) / Number(baseRate)
    base = (1 - 0.5) / (1 - 0.9)
    number = (0.6 / 0.1)
    n = Math.log(number) / Math.log(base)
    r = 0.1 * Math.pow((1 - 0.5) / (1 - uFloat), n)
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
  nn = total_interest / half
  fnn = Math.pow(2, nn)
  dn = total_supply / fnn
  return dn
}


function getInterectAllocateFIG(total_interest, new_interest) {

  total_supply = 480000000
  half = 900000
  dnn = getIntegralDN(total_interest + new_interest, total_supply, half)
  dnn_1 = getIntegralDN(total_interest, total_supply, half)
  fig = dnn_1 - dnn
  return Math.floor(fig)
}


function getStakeAllocateFIG(total_interest, new_interest) {
  total_supply = 720000000
  half = 5550000
  dnn = getIntegralDN(total_interest + new_interest, total_supply, half)
  dnn_1 = getIntegralDN(total_interest, total_supply, half)
  fig = dnn_1 - dnn
  return Math.floor(fig)
}

principal = BigInt(20e18)

annualRate = getAnnualRate(BigInt(50e18), principal, BASE_RATE)
console.log("annualRate: ", annualRate)

interest = calculateInterect(principal, 1051200n * 30n, annualRate, BASE_RATE)
principalInterect = principal + interest
console.log("principalInterect: ", principalInterect, "interest: ", interest)


borrowFee = getFee(principal, BORROW_FEE_RATE, BASE_RATE)
console.log("borrowFee: ", borrowFee)



// liquidity = BigInt(50e18) + 

fig = getInterectAllocateFIG(0, 1709116196590981160)
console.log("fig: ", fig)
