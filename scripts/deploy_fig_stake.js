const { parseEther } = require("ethers");
const { ethers, upgrades } = require("hardhat");

async function main() {

  let [owner] = await ethers.getSigners()
  const FILGovernance = await hre.ethers.getContractFactory("FILGovernance");
  const filGovernance = await FILGovernance.deploy("FILGovernance", "FIG")
  await filGovernance.addManager(owner.address)

  console.log("owner: ", owner)
  console.log("filGovernance.target: ", filGovernance.target)

  const periods = [[5, 86400*7], [10, 86400*30], [15, 86400*90], [25, 86400*180], [45, 86400*365]]


  const FIGStake = await hre.ethers.getContractFactory("FIGStake");
  const figStake = await FIGStake.deploy(filGovernance.target, owner.address, periods)
//   await figStake.connect(this.figStakeFoundation).setPeriods(this.periods);

  filGovernance.connect(owner).mint(owner.address, parseEther("10000000000"))

  console.log("figStake.target: ", figStake.target)

}

main();
