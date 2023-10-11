const CASE = {
    name: "",
    stepList: [
        {
          increaseBlockNumber: 3,
          contractName: "filLiquid",
          functionName: "collateralizingMiner",
          params: [101, "0x23"],
          value: BigInt(0),
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 4,
          contractName: "filLiquid",
          functionName: "deposit",
          params: [0],
          value: BigInt(50e18),
          signerIndex: 2,
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filLiquid",
          functionName: "borrow",
          params: [101, BigInt(20e18), 500000],
          value: BigInt(0),
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 1051200-1,
          contractName: "filLiquid",
          functionName: "directPayback",
          params: [101],
          value: BigInt(20e18),
          signerIndex: 5,
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
            totalFIL: BigInt(50e18) + 1709116196590981160n
          }
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filTrust",
          functionName: "balanceOf",
          params: ["__signer2"],
          value: BigInt(0),
          signerIndex: 0,
          results: {
            totalFIL: BigInt(50e18)
          }
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer1"],
          value: BigInt(0),
          signerIndex: 0,
          results: {
            totalFIL: BigInt(50e18)
          }
        },
      ]
}
module.exports.CASE = CASE;