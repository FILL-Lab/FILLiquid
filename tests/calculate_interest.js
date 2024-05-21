

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

const case_1 = require("./cases/case_1")

const parseEther = utils.parseEther


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
    console.log("has entered the deployLiquid")

    const [owner, otherAccount] = await ethers.getSigners()


    const FILTrust = await hre.ethers.getContractFactory("FILTrust");
    const filTrust = await FILTrust.deploy("FILTrust", "FIT")

    console.log("deployed filTrust")

    const Validation = await hre.ethers.getContractFactory("Validation");
    const validation = await Validation.deploy()

    
    const Stake = await hre.ethers.getContractFactory("FILStake");
    const stake = await Stake.deploy()

    const Calculation = await hre.ethers.getContractFactory("Calculation");
    const calculation = await Calculation.deploy()


    const FilecoinAPI = await hre.ethers.getContractFactory("FilecoinAPI");
    const filcoinAPI = await FilecoinAPI.deploy()


    const FILGovernance = await hre.ethers.getContractFactory("FILGovernance");
    const fILGovernance = await FILGovernance.deploy("FILGovernance", "FIG")

    console.log("deployed fILGovernance")

    const Governance = await hre.ethers.getContractFactory("Governance");
    const governance = await Governance.deploy()

    const FILLiquid = await hre.ethers.getContractFactory("FILLiquid")
    const liquid = await FILLiquid.deploy(filTrust.address, validation.address, calculation.address, filcoinAPI.address, stake.address, governance.address, owner.address, {gasLimit: 30000000})

    await governance.setContactAddrs(liquid.address, stake.address, fILGovernance.address)
    await stake.setContactAddrs(liquid.address, governance.address, filTrust.address, calculation.address, fILGovernance.address)

    await fILGovernance.addManager(liquid.address)
    await fILGovernance.addManager(stake.address)
    await filTrust.addManager(liquid.address)

    return { liquid, filTrust, validation, calculation, filcoinAPI, stake, governance, owner, otherAccount }
  }

  describe("Test flow", function () {
    it("Test all", async function () {
      const { liquid, filTrust, validation, calculation, filcoinAPI, stake, governance, owner, otherAccount } = await loadFixture(deployLiquid)

      principalInterest = await liquid.paybackAmount(BigInt(22e18), 31536000n, 83600n)
      console.log("principalInterest: ", principalInterest.toBigInt())

      await liquid.deposit(0, {value: BigInt(50e18)})

      rateBigNumber = await liquid.interestRateBorrow(BigInt(22e18))
      rate = rateBigNumber.toBigInt()
      console.log("rate: ", rate)
      

    })
  })
})
