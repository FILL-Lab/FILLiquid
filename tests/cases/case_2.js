const CASE = {
    name: "",
    stepList: [
        {
          mineBlockNumber: 1232,
          contractName: "filLiquid",
          functionName: "collateralizingMiner",
          params: [323, "0x23"],
          value: BigInt(0),
          signerIndex: 11,
        },
        {
          mineBlockNumber: 32123,
          contractName: "filLiquid",
          functionName: "collateralizingMiner",
          params: [1249934, "0x23"],
          value: BigInt(0),
          signerIndex: 12,
        },
        {
          mineBlockNumber: 84892,
          contractName: "filLiquid",
          functionName: "deposit",
          params: [0],
          value: BigInt(50e18),
          signerIndex: 2,
        },
        {
          mineBlockNumber: 23,
          contractName: "filLiquid",
          functionName: "deposit",
          params: [0],
          value: BigInt(230e18),
          signerIndex: 3,
        },
        {
          mineBlockNumber: 321,
          contractName: "filLiquid",
          functionName: "borrow",
          params: [1249934, BigInt(249934e18), 500000],
          value: BigInt(0),
          signerIndex: 11,
        },
        {
          mineBlockNumber: 3414,
          contractName: "filLiquid",
          functionName: "borrow",
          params: [323, BigInt(104e18), 500000],
          value: BigInt(0),
          signerIndex: 12,
        },
        {
          mineBlockNumber: 43402,
          contractName: "filLiquid",
          functionName: "directPayback",
          params: [323],
          value: BigInt(54e18),
          signerIndex: 5,
        },
        {
          mineBlockNumber: 3421,
          contractName: "filLiquid",
          functionName: "directPayback",
          params: [1249934],
          value: BigInt(10032e18),
          signerIndex: 5,
        },
      ],
    finalStateCheckList: [
        // {
        //   mineBlockNumber: 1023,
        //   contractName: "filLiquid",
        //   functionName: "getStatus",
        //   params: [],
        //   value: BigInt(0),
        //   signerIndex: 0,
        //   results: {
        //     totalFIL: BigInt(50e18) + 1909838600318976n
        //   }
        // },
        // {
        //   mineBlockNumber: 1023,
        //   contractName: "filTrust",
        //   functionName: "balanceOf",
        //   params: ["__signer2"],
        //   value: BigInt(0),
        //   signerIndex: 0,
        //   results: {
        //     totalFIL: BigInt(50e18)
        //   }
        // },
        // {
        //   mineBlockNumber: 1023,
        //   contractName: "filGovernance",
        //   functionName: "balanceOf",
        //   params: ["__signer1"],
        //   value: BigInt(0),
        //   signerIndex: 0,
        //   results: {
        //     totalFIL: BigInt(50e18)
        //   }
        // },
      ]
}
module.exports.CASE = CASE;