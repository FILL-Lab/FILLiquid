const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("withdrawFIG", function () {
  let contract;
  let tokenFILGovernance;
  let owner;
  let staker;
  let stakeId = 1;
  let stakeAmount = ethers.utils.parseEther("10");
  let withdrawableFIG = ethers.utils.parseEther("5");
  

  beforeEach(async function () {
    [owner, staker] = await ethers.getSigners();

    const TokenFILGovernance = await ethers.getContractFactory("FILGovernance");
    tokenFILGovernance = await TokenFILGovernance.deploy("FILGovernance", "FIG")
    await tokenFILGovernance.deployed();

    const Contract = await ethers.getContractFactory("FITStake");
    contract = await Contract.deploy();
    await contract.deployed();

    const singers = await ethers.getSigners()
    filLiquidMockSigner = singers[19]

    const FILTrust = await hre.ethers.getContractFactory("FILTrust");
    const filTrust = await FILTrust.deploy("FILTrust", "FIT")
    // console.log("deployed filTrust")

    const Calculation = await hre.ethers.getContractFactory("Calculation");
    const calculation = await Calculation.deploy()

    const FILGovernance = await hre.ethers.getContractFactory("FILGovernance");
    const filGovernance = await FILGovernance.deploy("FILGovernance", "FIG")
    // console.log("deployed filGovernance")

    const Governance = await hre.ethers.getContractFactory("Governance");
    const governance = await Governance.deploy()
    // console.log("deployed Governance")

    await contract.setContractAddrs(filLiquidMockSigner.address, governance.address, filTrust.address, calculation.address, filGovernance.address)
  });

  it("should transfer the FIG tokens to the staker's address when withdrawable", async function () {
    await contract.connect(staker).withdrawFIG(stakeId);
    const balance = await tokenFILGovernance.balanceOf(staker.address);
    expect(balance).to.equal(withdrawableFIG);
  });

  it("should not transfer any FIG tokens when not withdrawable", async function () {
    await contract.mockSetWithdrawableFIG(stakeId, 0);
    await contract.connect(staker).withdrawFIG(stakeId);
    const balance = await tokenFILGovernance.balanceOf(staker.address);
    expect(balance).to.equal(0);
  });

  it("should update releasedFIGSum and releasedFIGStake correctly", async function () {
    await contract.connect(staker).withdrawFIG(stakeId);
    const status = await contract.getStakerStatus(staker.address);
    expect(status.releasedFIGSum).to.equal(withdrawableFIG);
    const releasedFIGStake = await contract.releasedFIGStake();
    expect(releasedFIGStake).to.equal(withdrawableFIG);
  });

  // it("should emit WithdrawnFIG event correctly", async function () {
  //   await expect(contract.connect(staker).withdrawFIG(stakeId))
  //     .to.emit(contract, "WithdrawnFIG")
  //     .withArgs(staker.address, stakeId, withdrawableFIG);
  // });

  it("should revert if the stake ID is invalid", async function () {
    await expect(contract.connect(staker).withdrawFIG(999)).to.be.revertedWith("Invalid stakeId");
  });
});