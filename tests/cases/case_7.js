const ONE_ETHER = BigInt(1e18)
const RATE_BASE = 1000000n
const BORROW_FEE_RATE = 10000n
const REDEEM_FEE_RATE = 5000n


const CASE = {
    name: "",
    stepList: [
        {
          increaseBlockNumber: 4,
          contractName: "filLiquid",
          functionName: "deposit",
          params: [5000000],
          value: ONE_ETHER * 500n,
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 20,
          contractName: "filStake",
          functionName: "stakeFilTrust",
          params: [ONE_ETHER * 400n, 1025n, 1051200n / 2n],
          value: 0n,
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 3000,
          contractName: "filLiquid",
          functionName: "deposit",
          params: [5000000],
          value: ONE_ETHER * 100n,
          signerIndex: 2,
        },
        {
          increaseBlockNumber: 100,
          contractName: "filStake",
          functionName: "stakeFilTrust",
          params: [ONE_ETHER * 100n, 14124n, 1051200n / 4n],
          value: 0n,
          signerIndex: 2,
        },
        {
          increaseBlockNumber: 3000,
          contractName: "filLiquid",
          functionName: "deposit",
          params: [5000000],
          value: ONE_ETHER * 1000n,
          signerIndex: 3,
        },
        {
          increaseBlockNumber: 100,
          contractName: "filStake",
          functionName: "stakeFilTrust",
          params: [ONE_ETHER * 800n, 114124n, 1051200n / 4n],
          value: 0n,
          signerIndex: 3,
        },
        {
          increaseBlockNumber: 1023,
          contractName: "governance",
          functionName: "propose",
          params: [1, 2341, "lalalal", [223, 332]],
          value: 0n,
          signerIndex: 0,
        },
        {
          increaseBlockNumber: 1023,
          contractName: "governance",
          functionName: "bond",
          params: [ONE_ETHER * 18399n],
          value: 0n,
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 1000,
          contractName: "governance",
          functionName: "vote",
          params: [0, 0, ONE_ETHER * 18399n],
          value: 0n,
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 1000,
          contractName: "governance",
          functionName: "bond",
          params: [ONE_ETHER * 600000000n],
          value: 0n,
          signerIndex: 0,
        },
        {
          increaseBlockNumber: 1000,
          contractName: "governance",
          functionName: "vote",
          params: [0, 0, ONE_ETHER * 600000000n],
          value: 0n,
          signerIndex: 0,
        },
        {
          increaseBlockNumber: 40320,
          contractName: "governance",
          functionName: "execute",
          params: [0],
          value: 0n,
          signerIndex: 0,
        },
        {
          increaseBlockNumber: 1000,
          contractName: "governance",
          functionName: "unbond",
          params: [ONE_ETHER * 600000000n],
          value: 0n,
          signerIndex: 0,
        },
      ],
    finalStateCheckList: [
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer1"],
          value: 0,
          signerIndex: 0,
          results: 671868131878284840n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer2"],
          value: 0,
          signerIndex: 0,
          results: 2299925921949949027229n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer3"],
          value: 0,
          signerIndex: 0,
          results: 18399142887844966649083n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "totalSupply",
          params: [],
          value: 0,
          signerIndex: 0,
          results: 800000000000000000000000000n + 18399142887844966649083n + 2299925921949949027229n + 18399671868131878284840n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer0"],
          value: 0,
          signerIndex: 0,
          results: 800000000000000000000000000n
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filStake",
          functionName: "getAllFactors",
          params: [],
          value: 0,
          signerIndex: 0,
          results: [223n, 332n]
        }
      ]
}
module.exports.CASE = CASE;