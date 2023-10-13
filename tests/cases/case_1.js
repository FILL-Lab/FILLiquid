const ONE_ETHER = BigInt(1e18)

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
          params: [0],
          value: ONE_ETHER * 50000n,
          signerIndex: 2,
        },
        {
          increaseBlockNumber: 1023,
          contractName: "filLiquid",
          functionName: "borrow",
          params: [10323231, ONE_ETHER * 10000n, 500000],
          value: BigInt(0),
          signerIndex: 1,
        },
        {
          increaseBlockNumber: 1051200 * 40,
          contractName: "filLiquid",
          functionName: "directPayback",
          params: [10323231],
          value: ONE_ETHER * 10000n,
          signerIndex: 5,
        },
      ],
    finalStateCheckList: [
        // {
        //   increaseBlockNumber: 1023,
        //   contractName: "filLiquid",
        //   functionName: "getStatus",
        //   params: [],
        //   value: BigInt(0),
        //   signerIndex: 0,
        //   results: {
        //     totalFIL: ONE_ETHER * 70000n
        //   }
        // },
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