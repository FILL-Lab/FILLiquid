const { expect } = require("chai");
const { ethers } = require("hardhat");

const withdrawFIG = require("./functions/withdrawFIG");


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
    let filLiquid, filTrust, validation, calculation, filcoinAPI, fitStake, governance, filGovernance, owner, singer1, singer2, singer3, filLiquidMockSigner

    beforeEach(async function () {
        const singers = await ethers.getSigners()

        owner = singers[0]
        singer1 = singers[1]
        singer2 = singers[2]
        singer3 = singers[2]
        filLiquidMockSigner = singers[19]
    
    
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
    
        // return { filLiquid, filTrust, validation, calculation, filcoinAPI, fitStake, governance, filGovernance, owner, singer1, singer2, singer3, filLiquidMockSigner }
        this.fitStake = fitStake
    });

    it("should transfer the FIG tokens to the staker's address when withdrawable", async function () {
        let status = await fitStake.getStatus()
        // console.log("status: ", status)
        // console.log("withdrawFIG: ", withdrawFIG)
        // console.log("withdrawFIG.tests: ", withdrawFIG.tests)
    });

    withdrawFIG.tests(fitStake)
});