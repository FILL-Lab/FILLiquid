const ONE_ETHER = BigInt(1e18)
const RATE_BASE = 1000000n
const BORROW_FEE_RATE = 10000n
const REDEEM_FEE_RATE = 5000n


const CASE = {
    name: "",
    stepList: [
        {
          increaseBlockNumber: 3,
          contractName: "filLiquid",
          functionName: "collateralizingMiner",
          params: [10323231, "0x23"],
          value: BigInt(0),
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 4,
          contractName: "filLiquid",
          functionName: "deposit",
          params: [5000000],
          value: ONE_ETHER * 500000n,
          signerIndex: 2,
        },
        {
          increaseBlockNumber: 20,
          contractName: "filStake",
          functionName: "stakeFilTrust",
          params: [ONE_ETHER * 500000n, 1027n, 1051200n / 2n],
          value: 0n,
          signerIndex: 2,
        },
        {
          increaseBlockNumber: 1003,
          contractName: "filLiquid",
          functionName: "borrow",
          params: [10323231, ONE_ETHER * 200000n, 500000],
          value: BigInt(0),
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 1051200 * 5,
          contractName: "filLiquid",
          functionName: "directPayback",
          params: [10323231],
          value: ONE_ETHER * 150000n,
          signerIndex: 5,
        },
        {
          increaseBlockNumber: 100,
          contractName: "filLiquid",
          functionName: "collateralizingMiner",
          params: [4323231, "0x23"],
          value: BigInt(0),
          signerIndex: 11,
        },
        {
          increaseBlockNumber: 1000,
          contractName: "filLiquid",
          functionName: "borrow",
          params: [4323231, ONE_ETHER * 320000n, 500000],
          value: BigInt(0),
          signerIndex: 11,
        },
        {
          increaseBlockNumber: 2880 * 170,
          contractName: "filLiquid",
          functionName: "directPayback",
          params: [4323231],
          value: ONE_ETHER * 200000n,
          signerIndex: 11,
        },
      ],
    finalStateCheckList: [
        {
          increaseBlockNumber: 1023,
          contractName: "filLiquid",
          functionName: "getStatus",
          params: [],
          value: BigInt(0),
          signerIndex: 0,
          results: {
            totalFIL: ONE_ETHER * 500000n + 101363557022570715200000n + 40243690975934386880000n,
            availableFIL: 450000n * ONE_ETHER - 120000n * ONE_ETHER,
            utilizedLiquidity: 200000n * ONE_ETHER + 101363557022570715200000n - 150000n * ONE_ETHER + (ONE_ETHER * 120000n + 40243690975934386880000n),
            accumulatedDeposit: ONE_ETHER * 500000n,
            accumulatedRedeem: 0n,
            accumulatedBurntFILTrust: 0n,
            accumulatedMintFILTrust: ONE_ETHER * 500000n,
            accumulatedBorrow: 200000n * ONE_ETHER - ((200000n * ONE_ETHER) * BORROW_FEE_RATE / RATE_BASE) + (320000n * ONE_ETHER * (RATE_BASE - BORROW_FEE_RATE) / RATE_BASE),
            accumulatedPayback: 150000n * ONE_ETHER - 101363557022570715200000n + ONE_ETHER * 200000n - 40243690975934386880000n,
            accumulatedInterest: 101363557022570715200000n + 40243690975934386880000n,
            accumulatedRedeemFee: 0n,
            accumulatedBorrowFee: 2000n * ONE_ETHER + ((320000n * ONE_ETHER * BORROW_FEE_RATE) / RATE_BASE),
            // accumulatedLiquidateReward: _accumulatedLiquidateReward,
            // accumulatedLiquidateFee: _accumulatedLiquidateFee,
            accumulatedDeposits: 1n,
            accumulatedBorrows: 2n,
            accumulatedPaybackFILPeriod: ((150000n * ONE_ETHER) - 101363557022570715200000n) * 1051200n * 5n * 30n + (200000n * ONE_ETHER - 40243690975934386880000n) * (BigInt(2880 * 170) * 30n * 1n),
            utilizationRate: (50000n * ONE_ETHER + 101363557022570715200000n + 120000n * ONE_ETHER + 40243690975934386880000n) * RATE_BASE / (ONE_ETHER * 500000n + 101363557022570715200000n + 40243690975934386880000n),
            exchangeRate: ((101363557022570715200000n + 40243690975934386880000n + (500000n * ONE_ETHER)) * RATE_BASE)/ (500000n * ONE_ETHER),
            interestRate: 97419n,
            collateralizedMiner: 2n,
            minerWithBorrows: 2n,
            rateBase: RATE_BASE
          }
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filTrust",
          functionName: "balanceOf",
          params: ["__signer2"],
          value: BigInt(0),
          signerIndex: 0,
          results: 0n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer5"],
          value: BigInt(0),
          signerIndex: 0,
          results: 36046605930320094596948841n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer2"],
          value: BigInt(0),
          signerIndex: 0,
          results: 22636406937969680296986392n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filTrust",
          functionName: "balanceOf",
          params: ["__signer5"],
          value: BigInt(0),
          signerIndex: 0,
          results: 0n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filTrust",
          functionName: "balanceOf",
          params: ["__signer1"],
          value: BigInt(0),
          signerIndex: 0,
          results: 0n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer1"],
          value: BigInt(0),
          signerIndex: 0,
          results: 0n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer11"],
          value: BigInt(0),
          signerIndex: 0,
          results: 13548936608085169151626788n
        }
      ]
}
module.exports.CASE = CASE;