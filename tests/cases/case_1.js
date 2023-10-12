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
          value: BigInt(500000e18),
          signerIndex: 2,
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filLiquid",
          functionName: "borrow",
          params: [10323231, BigInt(20e18), 500000],
          value: BigInt(0),
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 1051200,
          contractName: "filLiquid",
          functionName: "directPayback",
          params: [10323231],
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
            totalFIL: BigInt(50e18) + 10155440213021967777792n
          }
        },
        // {
        //   increaseBlockNumber: 1023,
        //   contractName: "filTrust",
        //   functionName: "balanceOf",
        //   params: ["__signer2"],
        //   value: BigInt(0),
        //   signerIndex: 0,
        //   results: {
        //     totalFIL: BigInt(50e18)
        //   }
        // },
        {
          increaseBlockNumber: 1023,
          contractName: "filGovernance",
          functionName: "balanceOf",
          params: ["__signer5"],
          value: BigInt(0),
          signerIndex: 0,
          results: 3739604426469114898284544n
        },
      ]
}
module.exports.CASE = CASE;