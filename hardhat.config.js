require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("hardhat-deploy-ethers");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10,
      },
    },
  },
  defaultNetwork: "calibration",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      accounts: [
        {
          privateKey: "ec30c33546ddf1ce381e7a9be187bad34659048c182f1bd756e21d4733bd5998",
          balance: "99999900000000000000000000000000"
        }
      ]
    },
    wallaby: {
      chainId: 31415,
      url: "https://calibration.filfox.info/rpc/v0",
      accounts: [PRIVATE_KEY],
    },
    calibration: {
      chainId: 314159,
      url: "https://api.calibration.node.glif.io/rpc/v1",
      accounts: [PRIVATE_KEY],
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};
