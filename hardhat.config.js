require("@nomicfoundation/hardhat-toolbox");
const { vars } = require("hardhat/config");
const CALIBRATION_PRIVATE_KEY = vars.get("CALIBRATION_PRIVATE_KEY");
// const MAINNET_PRIVATE_KEY = vars.get("MAINNET_PRIVATE_KEY");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10,
      },
    },
  },
  defaultNetwork: "calibration",
  networks: {
    wallaby: {
      chainId: 31415,
      url: "https://calibration.filfox.info/rpc/v0",
      accounts: [CALIBRATION_PRIVATE_KEY],
    },
    calibration: {
      chainId: 314159,
      url: "https://api.calibration.node.glif.io/rpc/v1",
      accounts: [CALIBRATION_PRIVATE_KEY],
    },
    // mainnet: {
    //   chainId: 314,
    //   url: "https://api.node.glif.io/rpc/v1",
    //   accounts: [MAINNET_PRIVATE_KEY],
    // }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};
