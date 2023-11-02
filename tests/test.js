function calculatePrincipalInterect(principal, duration, annualRate, baseRate) {
  annualRateFloat = Number(annualRate) / Number(baseRate);
  exponent = (Number(duration) * Number(annualRateFloat)) / 31536000;
  console.log("exponent: ", exponent);
  console.log(principal, duration, annualRate, baseRate);
  return BigInt(Math.floor(Math.exp(exponent) * Number(principal)));
  // exponent = duration * annualRate * (BigInt(1e18) / baseRate) / 31536000n
  // BigInt(Math.floor(Math.exp(Number(exponent)))) * principal / BigInt(1e18)
}


interest = calculatePrincipalInterect(10000, 100, 3333, 1000000)
console.log("interest: ", interest)

u = (params.liquidity_fil - params.current_balance_fil) * params.rate_base / params.liquidity_fil
console.log("u: ", u, "amount: ", amount, "params.current_balance_fil: ", params.current_balance_fil,  "params.liquidity_fil: ", params.liquidity_fil)
interestRate = (10000n + 180000n) * u / params.rate_base
if (u > (params.rate_base / 2n)) {
  uFloat = Number(u) / Number(params.rate_base)
  base = (1 - 0.5) / (1 - 0.9)
  number = (0.6 / 0.1)
  n = Math.log(number) / Math.log(base)
  r = 0.1 * Math.pow((1 - 0.5) / (1 - uFloat), n)
  interestRate = BigInt(Math.floor(r * Number(params.rate_base)))
}

console.log("ended")

console.log("interestRate: ", interestRate)