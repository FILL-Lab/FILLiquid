require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("hardhat-deploy-ethers");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    // settings: {
    //   optimizer: {
    //     enabled: true,
    //     runs: 2000,
    //   },
    // },
    settings: {
      viaIR: true,
      optimizer: { enabled: true, runs: 10 },
    },
  },
  // defaultNetwork: "hyperspace",
  // networks: {
  //   wallaby: {
  //     chainId: 31415,
  //     url: "https://calibration.filfox.info/rpc/v0",
  //     accounts: [PRIVATE_KEY],
  //   },
  //   hyperspace: {
  //     chainId: 3141,
  //     url: "https://filecoin-hyperspace.chainup.net/rpc/v1",
  //     accounts: [PRIVATE_KEY],
  //   },
  // },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  }
};
