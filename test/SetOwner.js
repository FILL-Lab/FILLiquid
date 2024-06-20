const hre = require("hardhat");

async function main() {
  const fig = await hre.ethers.getContractAt("FILGovernance", "0x94B54F80B1747506D3E25e360d3085Ff8b25EcF2");
  await fig.setOwner("0x3BBcc9e6Ec7652A8AE41A9e84056FAeBAd7bc40e")
}

async function propose() {
  // transfer

  // changeOwner

  // renewSigners
}

async function approve() {
  // Input a proposeID

}

async function getProposeFromId(proposeId) {

}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});