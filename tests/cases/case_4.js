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
          increaseBlockNumber: 300,
          contractName: "filLiquid",
          functionName: "collateralizingMiner",
          params: [5323231, "0x23"],
          value: BigInt(0),
          signerIndex: 11,
        },
        {
          increaseBlockNumber: 1003,
          contractName: "filLiquid",
          functionName: "borrow",
          params: [5323231, ONE_ETHER * 140000n, 500000],
          value: BigInt(0),
          signerIndex: 11,
        },
        {
          increaseBlockNumber: 1051200 / 2,
          contractName: "filLiquid",
          functionName: "directPayback",
          params: [5323231],
          value: ONE_ETHER * 90000n,
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
            totalFIL: 608336340409512748280000n,
            availableFIL: 450000n * ONE_ETHER + 140000n * ONE_ETHER,
            utilizedLiquidity: 200000n * ONE_ETHER + 101363557022570715200000n - 150000n * ONE_ETHER + (140000n * ONE_ETHER + 6972783386942033080000n - 90000n * ONE_ETHER),
            accumulatedDeposit: ONE_ETHER * 500000n,
            accumulatedRedeem: 0n,
            accumulatedBurntFILTrust: 0n,
            accumulatedMintFILTrust: ONE_ETHER * 500000n,
            accumulatedBorrow: 200000n * ONE_ETHER - ((200000n * ONE_ETHER) * BORROW_FEE_RATE / RATE_BASE) + ((140000n * ONE_ETHER) - (140000n * ONE_ETHER) * BORROW_FEE_RATE/RATE_BASE),
            accumulatedPayback: 150000n * ONE_ETHER - 101363557022570715200000n + 90000n * ONE_ETHER - 6972783386942033080000n,
            accumulatedInterest: 101363557022570715200000n,
            accumulatedRedeemFee: 0n,
            accumulatedBorrowFee: 2000n * ONE_ETHER,
            // accumulatedLiquidateReward: _accumulatedLiquidateReward,
            // accumulatedLiquidateFee: _accumulatedLiquidateFee,
            accumulatedDeposits: 1n,
            accumulatedBorrows: 1n,
            accumulatedPaybackFILPeriod: ((150000n * ONE_ETHER) - 101363557022570715200000n) * 1051200n * 5n * 30n,
            utilizationRate: (50000n * ONE_ETHER + 101363557022570715200000n) * RATE_BASE / (ONE_ETHER * 500000n + 101363557022570715200000n),
            exchangeRate: ((101363557022570715200000n + (500000n * ONE_ETHER)) * RATE_BASE)/ (500000n * ONE_ETHER),
            interestRate: 55306n,
            collateralizedMiner: 1n,
            minerWithBorrows: 1n,
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
      ]
}
module.exports.CASE = CASE;