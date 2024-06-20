
const hre = require("hardhat");

const FIGAddress =  "0x7B87D63001229f016398F0623eD2fBA07e50a81d";
async function main() {
  const filGovernance = await hre.ethers.getContractAt("FILGovernance", FIGAddress);
  console.log(await filGovernance.balanceOf("0x3BBcc9e6Ec7652A8AE41A9e84056FAeBAd7bc40e"));
  console.log(await filGovernance.balanceOf("0xf846c57f1de0521d6af703026f132B0Cd7E93C2A"));
  console.log(await filGovernance.balanceOf(""))
  // console.log(await filGovernance.balanceOf("0x7B87D63001229f016398F0623eD2fBA07e50a81d"));
}



main();