
const case_1 = require("./cases/case_8")

const hre = require('hardhat')
const { ethers } = require('hardhat')
const ethersRaw = require('ethers')

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

const DEFAULT_N_INTEREST = 1.2e25;
const DEFAULT_N_STAKE = 1.36449194112e31;
const DEFAULT_MIN_STAKE_PERIOD = 86400; //30 days
const DEFAULT_MAX_STAKE_PERIOD = 1036800; //360 days
const DEFAULT_MIN_STAKE = ONE_ETHER;
const DEFAULT_MAX_STAKES = 100;
const DEFAULT_RATE_BASE = 10;
const DEFAULT_INTEREST_SHARE = 4;
const DEFAULT_STAKE_SHARE = 6;


const OWNER_DEPOSIT_FIL = ONE_ETHER * 1000n;
const SIGNER1_DEPOSIT_FIL = ONE_ETHER * 5000n;
const SIGNER2_DEPOSIT_FIL = ONE_ETHER * 10000n;
const SIGNER3_DEPOSIT_FIL = ONE_ETHER * 10000n;

describe("FITStake", function () {
  async function beforeEach() {
    console.log("beforeEach")
  }
  async function deployAllContracts() {
    const singers = await ethers.getSigners()

    let owner = singers[0]
    let singer1 = singers[1]
    let singer2 = singers[2]
    let singer3 = singers[2]
    filLiquidMockSigner = singers[19]


    const FILTrust = await hre.ethers.getContractFactory("FILTrust");
    const filTrust = await FILTrust.deploy("FILTrust", "FIT")

    // console.log("deployed filTrust")

    const Validation = await hre.ethers.getContractFactory("Validation");
    const validation = await Validation.deploy()

    const FITStake = await hre.ethers.getContractFactory("FITStake");
    const fitStake = await FITStake.deploy()

    const Calculation = await hre.ethers.getContractFactory("Calculation");
    const calculation = await Calculation.deploy()

    const FilecoinAPI = await hre.ethers.getContractFactory("FilecoinAPI");
    const filcoinAPI = await FilecoinAPI.deploy()

    const FILGovernance = await hre.ethers.getContractFactory("FILGovernance");
    const filGovernance = await FILGovernance.deploy("FILGovernance", "FIG")
    // console.log("deployed filGovernance")

    const Governance = await hre.ethers.getContractFactory("Governance");
    const governance = await Governance.deploy()
    // console.log("deployed Governance")

    const FILLiquid = await hre.ethers.getContractFactory("FILLiquid")
    const filLiquid = await FILLiquid.deploy(filTrust.address, validation.address, calculation.address, filcoinAPI.address, fitStake.address, governance.address, owner.address, {gasLimit: 30000000})
    // console.log("deployed FILLiquid")

    await governance.setContractAddrs(filLiquidMockSigner.address, fitStake.address, filGovernance.address)

    await fitStake.setContractAddrs(filLiquidMockSigner.address, governance.address, filTrust.address, calculation.address, filGovernance.address)

    await filGovernance.addManager(filLiquid.address)
    await filGovernance.addManager(fitStake.address)
    await filGovernance.addManager(governance.address)
    await filTrust.addManager(filLiquid.address)
    await filTrust.addManager(fitStake.address)

    mineBlockNumberHex = `0x${(3000).toString(16)}`
    await hre.network.provider.send("hardhat_mine", [mineBlockNumberHex, "0x1"]);

    await filLiquid.connect(owner).deposit(OWNER_DEPOSIT_FIL, {value: OWNER_DEPOSIT_FIL})
    await filLiquid.connect(singer1).deposit(SIGNER1_DEPOSIT_FIL, {value: SIGNER1_DEPOSIT_FIL})
    await filLiquid.connect(singer2).deposit(SIGNER2_DEPOSIT_FIL, {value: SIGNER2_DEPOSIT_FIL})
    await filLiquid.connect(singer3).deposit(SIGNER3_DEPOSIT_FIL, {value: SIGNER3_DEPOSIT_FIL})

    return { filLiquid, filTrust, validation, calculation, filcoinAPI, fitStake, governance, filGovernance, owner, singer1, singer2, singer3, filLiquidMockSigner }
  }

  // describe("tttt", function () {
  //   it("onlyFiLLiquid", async function () {
  //     r = await deployAllContracts()
  //   })
  // })

  describe("handleInterest", function () {
    it("onlyFiLLiquid", async function () {
      const {fitStake, governance, filGovernance, owner, singer1, filLiquidMockSigner } = await loadFixture(deployAllContracts)
      let promise = fitStake.handleInterest(singer1.address, parseEther("143.2"), parseEther("3.2"))
      await expect(promise).to.be.revertedWith("Only filLiquid allowed")

      let promise2 = fitStake.connect(singer1).handleInterest(singer1.address, parseEther("143.2"), parseEther("3.2"))
      await expect(promise2).to.be.revertedWith("Only filLiquid allowed")

      await fitStake.connect(filLiquidMockSigner).handleInterest(singer1.address, parseEther("143.2"), parseEther("3.2"))
    })

    it("Normal tests", async function () {
      const {fitStake, governance, filGovernance, owner, singer1, filLiquidMockSigner } = await loadFixture(deployAllContracts)

      await fitStake.connect(filLiquidMockSigner).handleInterest(singer1.address, parseEther("143.2"), parseEther("3.2"))

    })
  })

  describe("stakeFilTrust", function () {
    
    it("Amount too small", async function () {
      const {fitStake, governance, filGovernance, owner, singer1, filLiquidMockSigner } = await loadFixture(deployAllContracts)

      let promise1 = fitStake.connect(filLiquidMockSigner).stakeFilTrust(DEFAULT_MIN_STAKE-1n, 100, parseEther("3.2"))
      await expect(promise1).to.be.revertedWith("Amount too small")
    })

    it("Block height exceeds", async function () {
      const {fitStake, governance, filGovernance, owner, singer1, filLiquidMockSigner } = await loadFixture(deployAllContracts)

      console.log("block.number: ", (await ethers.provider.getBlock()).number)

      let promise1 = fitStake.connect(singer1).stakeFilTrust(DEFAULT_MIN_STAKE, 1, DEFAULT_MIN_STAKE_PERIOD+1)
      await expect(promise1).to.be.revertedWith("Block height exceeds")
    })

    it("Invalid duration", async function () {
      const {fitStake, governance, filGovernance, owner, singer1, filLiquidMockSigner } = await loadFixture(deployAllContracts)

      let promise1 = fitStake.connect(filLiquidMockSigner).stakeFilTrust(DEFAULT_MIN_STAKE, 10000, DEFAULT_MIN_STAKE_PERIOD-1)
      await expect(promise1).to.be.revertedWith("Invalid duration")

      let promise2 = fitStake.connect(filLiquidMockSigner).stakeFilTrust(DEFAULT_MIN_STAKE, 10000, DEFAULT_MAX_STAKE_PERIOD+1)
      await expect(promise2).to.be.revertedWith("Invalid duration")
    })

    it("StakerStatus", async function () {
      const {fitStake, governance, filGovernance, owner, singer1, singer2, singer3, filLiquidMockSigner } = await loadFixture(deployAllContracts)

      // await fitStake.connect(owner).stakeFilTrust(DEFAULT_MIN_STAKE, 13332, 2880*30)
      await fitStake.connect(singer2).stakeFilTrust(ONE_ETHER * 10000n, 10003230, 2880*30)
      await fitStake.connect(singer3).stakeFilTrust(ONE_ETHER * 10000n, 10000434, 2880*30)

      let stakerStatus = await fitStake.getStakerStakes(singer2.address)
      // console.log("stakerStatus: ", stakerStatus)

      // expect(stakerStatus.stakeSum).to.be.equal(1200)
      // expect(stakerStatus.totalFIGSum).to.be.equal(0)
      // expect(stakerStatus.releasedFIGSum).to.be.equal(0)
      // expect(stakerStatus.Stake.length).to.be.equal(2)

    })

    

    it("Normal tests", async function () {
      const {fitStake, governance, filGovernance, owner, singer1, filLiquidMockSigner } = await loadFixture(deployAllContracts)

      await fitStake.connect(filLiquidMockSigner).handleInterest(singer1.address, parseEther("143.2"), 2880 * 30)

    })
  })

  describe("withdrawFIG", function () {
    let fitStake, governance, filGovernance, owner, singer1, singer2, singer3, filLiquidMockSigner;
  
    beforeEach(async function () {
      [fitStake, governance, filGovernance, owner, singer1, singer2, singer3, filLiquidMockSigner ] = await loadFixture(deployAllContracts)

      console.log("fitStake--------: ", fitStake)
    });
  
    // it("should transfer the FIG tokens to the staker's address when withdrawable", async function () {
    //   await fitStake.connect(staker).withdrawFIG(stakeId);
    //   const balance = await tokenFILGovernance.balanceOf(staker.address);
    //   expect(balance).to.equal(withdrawableFIG);
    // });
  
    // it("should not transfer any FIG tokens when not withdrawable", async function () {
    //   await fitStake.mockSetWithdrawableFIG(stakeId, 0);
    //   await fitStake.connect(staker).withdrawFIG(stakeId);
    //   const balance = await tokenFILGovernance.balanceOf(staker.address);
    //   expect(balance).to.equal(0);
    // });
  
    // it("should update releasedFIGSum and releasedFIGStake correctly", async function () {
    //   await fitStake.connect(staker).withdrawFIG(stakeId);
    //   const status = await fitStake.getStakerStatus(staker.address);
    //   expect(status.releasedFIGSum).to.equal(withdrawableFIG);
    //   const releasedFIGStake = await fitStake.releasedFIGStake();
    //   expect(releasedFIGStake).to.equal(withdrawableFIG);
    // });
  
    // it("should emit WithdrawnFIG event correctly", async function () {
    //   await expect(fitStake.connect(staker).withdrawFIG(stakeId))
    //     .to.emit(fitStake, "WithdrawnFIG")
    //     .withArgs(staker.address, stakeId, withdrawableFIG);
    // });
  
    it("should revert if the stake ID is invalid", async function () {
      await expect(fitStake.connect(staker).withdrawFIG(999)).to.be.revertedWith("Invalid stakeId");
    });
  });
})
