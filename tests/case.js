
const case_1 = require("./cases/case_6")

const hre = require('hardhat')
const { ethers } = require('hardhat')

const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers")
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs")
const { expect } = require("chai")

const { BigNumber, BigNumberish } = require("@ethersproject/bignumber")
const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers')
const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { assert } = require("console")
const { transaction } = require("@openzeppelin/test-helpers/src/send")
const { duration } = require("@openzeppelin/test-helpers/src/time")

const parseEther = utils.parseEther

const ONE_ETHER = BigInt(1e18)

const INIT_FEE_RATE = 100
const INIT_MANAGER = "0xa293B3d8EF9F2318F7E316BF448e869e8833ec63"
const FEE_RATE_TOTAL = 10000
const MAX_COMMISSION = 500e18

// const [owner] = await ethers.getSigners()

// const INIT_FOUNDATION_ADDRESS = owner.address
const INIT_MAX_DEBT_RATE = 400000

// const SPex = artifacts.require('SPex')


describe("Liquid", function () {
  async function deployLiquid() {

    const [owner, otherAccount] = await ethers.getSigners()


    const FILTrust = await hre.ethers.getContractFactory("FILTrust");
    const filTrust = await FILTrust.deploy("FILTrust", "FIT")

    console.log("deployed filTrust")

    const Validation = await hre.ethers.getContractFactory("Validation");
    const validation = await Validation.deploy()

    
    const FILStake = await hre.ethers.getContractFactory("FILStake");
    const filStake = await FILStake.deploy()

    const Calculation = await hre.ethers.getContractFactory("Calculation");
    const calculation = await Calculation.deploy()


    const FilecoinAPI = await hre.ethers.getContractFactory("FilecoinAPI");
    const filcoinAPI = await FilecoinAPI.deploy()


    const FILGovernance = await hre.ethers.getContractFactory("FILGovernance");
    const filGovernance = await FILGovernance.deploy("FILGovernance", "FIG")

    console.log("deployed filGovernance")

    const Governance = await hre.ethers.getContractFactory("Governance");
    const governance = await Governance.deploy()

    const FILLiquid = await hre.ethers.getContractFactory("FILLiquid")
    const filLiquid = await FILLiquid.deploy(filTrust.address, validation.address, calculation.address, filcoinAPI.address, filStake.address, governance.address, owner.address, {gasLimit: 30000000})

    await governance.setContactAddrs(filLiquid.address, filStake.address, filGovernance.address)
    await filStake.setContactAddrs(filLiquid.address, governance.address, filTrust.address, calculation.address, filGovernance.address)

    await filGovernance.addManager(filLiquid.address)
    await filGovernance.addManager(filStake.address)
    await filTrust.addManager(filLiquid.address)
    await filTrust.addManager(filStake.address)

    return { filLiquid, filTrust, validation, calculation, filcoinAPI, filStake, governance, filGovernance, owner, otherAccount }
  }

  function getProcessedParams(params, signers) {
    newParams = []
    for (let item of params) {
      if (typeof(item) === "string") {
        if (item.startsWith("__signer")) {
          signerIndex = Number(item.split("__signer")[1])
          signer = signers[signerIndex]
          newParams.push(signer.address)
          continue
        }
      }
      newParams.push(item)
    }
    return newParams
  }

  describe("Test flow", function () {
    it("Test all", async function () {
      // const { filLiquid, filTrust, validation, calculation, filcoinAPI, stake, governance, owner, otherAccount } = await loadFixture(deployLiquid)

      // console.log("CASE: ", CASE)
      // console.log("case_1: ", case_1)

      defaultSigners = await ethers.getSigners()
      sender = defaultSigners[0]
      signers = [sender]


      for (let i=0; i<100; i++) {
        wallet = ethers.Wallet.createRandom()
        signer = wallet.connect(ethers.provider)
        amount = 100000000000000000000000000000n
        sendTransaction = {
          to: signer.address,
          value: amount
        }
        await sender.sendTransaction(sendTransaction)
        signers.push(signer)


        // block = await ethers.provider.getBlock()
        // console.log("block.timestamp: ", block.timestamp)
      }

      const contracts = await loadFixture(deployLiquid)
      // const signers = await ethers.getSigners()
      
      let stepList = case_1.CASE.stepList

      let finalStateCheckList = case_1.CASE.finalStateCheckList

      contract = contracts.filLiquid
      principalAndInterest = await contract.paybackAmount(BigInt(ONE_ETHER * 200000n), 31536000n*5n, 82000n)
      // console.log("principalAndInterest: ", principalAndInterest.toBigInt())

      mineBlockNumberHex = `0x${(887).toString(16)}`
      await hre.network.provider.send("hardhat_mine", [mineBlockNumberHex, "0x1"]);

      block = await ethers.provider.getBlock()
      console.log("block.number: ", block.number)

      lastTimestamp = (await ethers.provider.getBlock()).timestamp

      for (stepIndex in stepList) {
        step = stepList[stepIndex]
        console.log(`checkStepIndex: ${stepIndex} step.contractName: ${step.contractName} step.functionName: ${step.functionName}`)

        // if(step.functionName === "directPayback") {
        //   tx = await contract.callStatic.minerBorrows(...step.params)
        //   console.log("minerBorrows: ", tx)
        // }

        if(step.mineBlockNumber < 2) {
          throw("step.mineBlockNumber < 2")
        }
        // mineBlockNumberHex = `0x${step.mineBlockNumber.toString(16)}`
        mineBlockNumberHex = `0x${(step.increaseBlockNumber-2).toString(16)}`
        await hre.network.provider.send("hardhat_mine", [mineBlockNumberHex, "0x1"]);

        lastTimestamp += step.increaseBlockNumber*30
        await hre.network.provider.send("evm_setNextBlockTimestamp", [`0x${(lastTimestamp).toString(16)}`])


        contract = contracts[step.contractName]
        signer = signers[step.signerIndex]
        // console.log("signer: ", signer)
        // console.log("signers: ", signers)
        // console.log("step.signerIndex: ", step.signerIndex)
        newParams = getProcessedParams(step.params, signers)
        // console.log("newParams: ", newParams)

        tx = await contract.connect(signer)[step.functionName](...newParams, {value: step.value})
        result = await tx.wait()

        block = await ethers.provider.getBlock()
        console.log("block.number: ", block.number)

        // block = await ethers.provider.getBlock()

        sendTransaction = {
          to: signer.address,
          value: result.cumulativeGasUsed.toBigInt() * result.effectiveGasPrice.toBigInt()
        }
        await signers[0].sendTransaction(sendTransaction)

        // await hre.network.provider.send("hardhat_mine", [`0x${(1).toString(16)}`, `0x${(98).toString(16)}`]);

        // try {
        //   interestRate = await contract.interestRateBorrow(BigInt(ONE_ETHER * 320000n))
        //   console.log("interestRate: ", interestRate.toBigInt())
          
        //   maxBorrowAllowedByUtilization = await contract.maxBorrowAllowedByUtilization()
        //   totalFILLiquidity = await contract.totalFILLiquidity()
        //   utilizedLiquidity = await contract.utilizedLiquidity()
        //   console.log("maxBorrowAllowedByUtilization: ", maxBorrowAllowedByUtilization.toBigInt())
        //   console.log("totalFILLiquidity: ", totalFILLiquidity.toBigInt())
        //   console.log("utilizedLiquidity: ", utilizedLiquidity.toBigInt())

        //   liquidStatus = await contracts.filLiquid.getStatus()
        //   console.log("liquidStatus: ", liquidStatus)
        // }catch(error) {

        // }
      }

      for (stepIndex in finalStateCheckList) {
        step = finalStateCheckList[stepIndex]
        console.log(`checkStepIndex: ${stepIndex} step.contractName: ${step.contractName} step.functionName: ${step.functionName}`)

        // if(step.mineBlockNumber < 1) {
        //   throw("step.mineBlockNumber < 1")
        // }
        // mineBlockNumberHex = `0x${(step.increaseBlockNumber-1).toString(16)}`
        // await hre.network.provider.send("hardhat_mine", [mineBlockNumberHex, "0x1"]);

        // lastTimestamp += step.increaseBlockNumber*30
        // await hre.network.provider.send("evm_setNextBlockTimestamp", [`0x${(lastTimestamp).toString(16)}`])

        contract = contracts[step.contractName]
        signer = signers[step.signerIndex]

        
        newParams = getProcessedParams(step.params, signers)

        // console.log("newParams: ", newParams)

        // console.log("step.contractName: ", step.contractName, "contract: ", contract)

        results = await contract.connect(signer)[step.functionName](...newParams, {value: step.value})

        // console.log("step.functionName: ", step.functionName, "step.contractName: ", step.contractName, "results: ", results)

        typeOfStepResults = typeof(step.results)

        // console.log("typeOfStepResults: ", typeOfStepResults)

        // if (Array.isArray(step.results)){
          
        // }else 
        if (typeOfStepResults === "object") {
          for (let key of Object.keys(step.results)) {
            targetValue = step.results[key]
            resultValue = results[key]
            if (BigNumber.isBigNumber(resultValue)) {
              resultValue = resultValue.toBigInt()
            }
            if (resultValue !== targetValue) {
              throw(`return value is not match expected key: ${key} targetValue: ${targetValue} resultValue: ${resultValue}`)
            }
          }
        }else if (typeOfStepResults === "bigint") {
          resultValue = results.toBigInt()
          if (resultValue !== step.results) {
            throw(`return value is not match expected step.results: ${step.results} resultValue: ${resultValue}`)
          }
        }
        else {
          // if (BigNumber.isBigNumber(results)) {
          //   resultValue = results.toBigInt()
          //   if (resultValue !== targetValue) {
          //     throw(`return value is not match expected targetValue: ${targetValue} resultValue: ${resultValue}`)
          //   }
          // }
          throw(`Unknown type of step.results ${typeOfStepResults}`)
        }
      }
    })
  })
})
