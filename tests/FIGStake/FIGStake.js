const { expect } = require("chai");
const { ethers } = require("hardhat");

const stakeFilGovernance = require("./functions/stakeFilGovernance");


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

        this.ONE_ETHER = BigInt(1e18)

        this.DEFAULT_MIN_STAKE = this.ONE_ETHER;
        this.DEFAULT_MAX_STAKES_PER_STAKER = 100;
        this.RATE_BASE = 1000000;
        this.STAKE_PERIOD_0 = 0;
        this.STAKE_RATE_0 = 1;
        this.STAKE_PERIOD_1 = 86400; //30 days
        this.STAKE_RATE_1 = 2;
        this.STAKE_PERIOD_2 = 259200; //90 days
        this.STAKE_RATE_2 = 3;
        this.STAKE_PERIOD_3 = 518400; //180 days
        this.STAKE_RATE_3 = 4;
        this.STAKE_PERIOD_4 = 777600; //270 days
        this.STAKE_RATE_4 = 5;
        this.STAKE_PERIOD_5 = 1036800; //360 days
        this.STAKE_RATE_5 = 6;

        this.owner = signers[0]
        this.signer1 = signers[1]
        this.signer2 = signers[2]
        this.signer3 = signers[3]
        this.signer4 = signers[4]
        this.signer11 = signers[11]
        this.signer12 = signers[12]
        this.figManager = signers[19]
        this.fitStakeFoundation = signers[19]

        this.signer1FIGAmount = this.ONE_ETHER * 1000000000000n
        this.signer2FIGAmount = this.ONE_ETHER * 2000000000000n
        this.signer3FIGAmount = this.ONE_ETHER * 3000000000000n
        this.signer4FIGAmount = this.ONE_ETHER * 4000000000000n

        this.mineBlocks = mineBlocks

        const FILGovernance = await hre.ethers.getContractFactory("FILGovernance");
        const filGovernance = await FILGovernance.deploy("FILGovernance", "FIG")
        await filGovernance.addManager(this.figManager.address)

        const FIGStake = await hre.ethers.getContractFactory("FIGStake");
        const figStake = await FIGStake.deploy(filGovernance.address, this.fitStakeFoundation.address)

        filGovernance.connect(this.figManager).mint(this.signer1.address, this.signer1FIGAmount)
        filGovernance.connect(this.figManager).mint(this.signer2.address, this.signer2FIGAmount)
        filGovernance.connect(this.figManager).mint(this.signer3.address, this.signer3FIGAmount)
        filGovernance.connect(this.figManager).mint(this.signer4.address, this.signer4FIGAmount)

        this.filGovernance = filGovernance
        this.figStake = figStake
        
    });

    stakeFilGovernance.tests()
});