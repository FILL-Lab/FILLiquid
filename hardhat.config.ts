require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("hardhat-deploy-ethers");
require("dotenv").config();
import { HardhatUserConfig } from "hardhat/config";

const PRIVATE_KEY = process.env.PRIVATE_KEY;
/** @type import('hardhat/config').HardhatUserConfig */
const config: HardhatUserConfig = {
  mocha: {
    timeout: 600000,
  },
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
  networks: {
    hardhat: {
      accounts: [
        {
          privateKey: "ec30c33546ddf1ce381e7a9be187bad34659048c182f1bd756e21d4733bd5998",
          balance: "99999900000000000000000000000000"
        }
      ]
    },
    // wallaby: {
    //   chainId: 31415,
    //   url: "https://calibration.filfox.info/rpc/v0",
    //   accounts: [PRIVATE_KEY],
    // },
    // hyperspace: {
    //   chainId: 3141,
    //   url: "https://filecoin-hyperspace.chainup.net/rpc/v1",
    //   accounts: [PRIVATE_KEY],
    // },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  }
};
export default config;
