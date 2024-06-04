const { expect } = require("chai");
const { ethers } = require("hardhat");

const bound = require("./functions/bond");
const unbound = require("./functions/unbond");
const propose = require("./functions/propose");
const vote = require("./functions/vote");
const execute = require("./functions/execute");
const getVoteResult = require("./functions/getVoteResult");

const ONE_ETHER = BigInt(1e18)

const OWNER_DEPOSIT_FIL = ONE_ETHER * 1000n;
const SIGNER1_DEPOSIT_FIL = ONE_ETHER * 10000n;
const SIGNER2_DEPOSIT_FIL = ONE_ETHER * 200000n;
const SIGNER3_DEPOSIT_FIL = ONE_ETHER * 300000n;

async function mineBlocks(blockNumber) {
    mineBlockNumberHex = `0x${(blockNumber).toString(16)}`
    await hre.network.provider.send("hardhat_mine", [mineBlockNumberHex, "0x1"]);
  
    let lastTimestamp = (await ethers.provider.getBlock()).timestamp
    lastTimestamp += blockNumber * 30
    await hre.network.provider.send("evm_setNextBlockTimestamp", [`0x${(lastTimestamp).toString(16)}`])
  }


describe("Governance", function () {
    // let filLiquid, filTrust, validation, calculation, filcoinAPI, fitStake, governance, filGovernance, owner, signer1, signer2, signer3

    beforeEach(async function () {
        const signers = await ethers.getSigners()

        owner = signers[0]
        signer1 = signers[1]
        signer2 = signers[2]
        signer3 = signers[3]
        signer4 = signers[4]

        // console.log("(await ethers.provider.getBalance(signer2.address)).toBigInt(): ", (await ethers.provider.getBalance(signer2.address)).toBigInt())
    
        const FILTrust = await hre.ethers.getContractFactory("FILTrust");
        filTrust = await FILTrust.deploy("FILTrust", "FIT")
    
        // console.log("deployed filTrust")
    
        const Validation = await hre.ethers.getContractFactory("Validation");
        validation = await Validation.deploy()
    
        const FITStake = await hre.ethers.getContractFactory("FITStake");
        fitStake = await FITStake.deploy()
    
        const Calculation = await hre.ethers.getContractFactory("Calculation");
        calculation = await Calculation.deploy()
    
        const FilecoinAPI = await hre.ethers.getContractFactory("FilecoinAPI");
        filcoinAPI = await FilecoinAPI.deploy()
    
        const FILGovernance = await hre.ethers.getContractFactory("FILGovernance");
        filGovernance = await FILGovernance.deploy("FILGovernance", "FIG")
        // console.log("deployed filGovernance")
    
        const Governance = await hre.ethers.getContractFactory("Governance");
        governance = await Governance.deploy()
        // console.log("deployed Governance")
    
        const FILLiquid = await hre.ethers.getContractFactory("FILLiquid")
        filLiquid = await FILLiquid.deploy(filTrust.address, validation.address, calculation.address, filcoinAPI.address, fitStake.address, governance.address, owner.address, {gasLimit: 30000000})
        // console.log("deployed FILLiquid")
    
        await governance.setContractAddrs(filLiquid.address, fitStake.address, filGovernance.address)
    
        await fitStake.setContractAddrs(filLiquid.address, governance.address, filTrust.address, calculation.address, filGovernance.address)
    
        await filGovernance.addManager(filLiquid.address)
        await filGovernance.addManager(fitStake.address)
        await filGovernance.addManager(governance.address)
        await filTrust.addManager(filLiquid.address)
        await filTrust.addManager(fitStake.address)
    
        mineBlockNumberHex = `0x${(3000).toString(16)}`
        await hre.network.provider.send("hardhat_mine", [mineBlockNumberHex, "0x1"]);
    
        await filLiquid.connect(owner).deposit(OWNER_DEPOSIT_FIL, {value: OWNER_DEPOSIT_FIL})
        await filLiquid.connect(signer1).deposit(SIGNER1_DEPOSIT_FIL, {value: SIGNER1_DEPOSIT_FIL})
        await filLiquid.connect(signer2).deposit(SIGNER2_DEPOSIT_FIL, {value: SIGNER2_DEPOSIT_FIL})
        await filLiquid.connect(signer3).deposit(SIGNER3_DEPOSIT_FIL, {value: SIGNER3_DEPOSIT_FIL})

        await fitStake.connect(owner).stakeFilTrust(OWNER_DEPOSIT_FIL, 100230000, 2880 * 360)
        await fitStake.connect(signer1).stakeFilTrust(SIGNER1_DEPOSIT_FIL, 100230000, 2880 * 360)
        await fitStake.connect(signer2).stakeFilTrust(SIGNER2_DEPOSIT_FIL, 100230000, 2880 * 360)
        await fitStake.connect(signer3).stakeFilTrust(SIGNER3_DEPOSIT_FIL, 100230000, 2880 * 360)

        await mineBlocks(2880 * 360)

        await fitStake.connect(owner).unStakeFilTrust(0)
        await fitStake.connect(signer1).unStakeFilTrust(1)
        await fitStake.connect(signer2).unStakeFilTrust(2)
        await fitStake.connect(signer3).unStakeFilTrust(3)

    
        // return { filLiquid, filTrust, validation, calculation, filcoinAPI, fitStake, governance, filGovernance, owner, signer1, signer2, signer3 }
        this.filLiquid = filLiquid
        this.filGovernance = filGovernance
        this.filTrust = filTrust
        this.validation = validation
        this.calculation = calculation
        this.filcoinAPI = filcoinAPI
        this.fitStake = fitStake
        this.governance = governance
        this.owner = owner
        this.signer1 = signer1
        this.signer2 = signer2
        this.signer3 = signer3
        this.signer4 = signer4

        this.mineBlocks = mineBlocks

        this.DEFAULT_RATEBASE = 1000000;
        this.DEFAULT_MIN_YES = 500000;
        this.DEFAULT_MAX_NO = 333333;
        this.DEFAULT_MAX_NO_WITH_VETO = 333333;
        this.DEFAULT_QUORUM = 400000;
        this.DEFAULT_LIQUIDATE = 200000;
        this.DEFAULT_DEPOSIT_RATIO_THRESHOLD = 10;    // 0.001% (10/1000000)
        this.DEFAULT_DEPOSIT_AMOUNT_THRESHOLD = 1e22;  // 10000FIG 
        this.DEFAULT_VOTE_THRESHOLD = 1e19;
        this.DEFAULT_VOTING_PERIOD = 40320; // 14 days
        this.DEFAULT_EXECUTION_PERIOD = 20160; // 7 days
        this.DEFAULT_GRID = 2880; // 1 days
        this.DEFAULT_MAX_ACTIVE_PROPOSAL = 1000;
        this.MAX_TEXT_LENGTH = 5000;

        this.ONE_ETHER = BigInt(1e18)
    });

    // bound.tests()
    // unbound.tests()
    // propose.tests()
    // vote.tests()
    // execute.tests()
    getVoteResult.tests()
});