const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers, ignition } = require("hardhat");

const FILLModule = require("../ignition/modules/FILL");

describe("FILL test", function() {
    async function deployALL() {
        await ignition.deploy(FILLModule, "../ignition/modules/example_params.json");
    }

    it("DeployFLL", async function () {
        const [owner] = await ethers.getSigners();
        
        const deployer = await loadFixture(deployALL);
        console.log(deployer);
        // fiLLiquid.getFitByDeposit()
    
        // const ownerBalance = await hardhatToken.balanceOf(owner.address);
        // expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
      });
});
