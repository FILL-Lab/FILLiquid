
const DeployerFILLAddress = "0xA4B947ADD8b6A2a8f3Ad5F9e8B5fd773B79BA9a5"
const DeployerDataFetcherAddress = "0x1BF0926A15a93C8F40701F6615e280aA04A6B873"
const hre = require("hardhat");

async function main() {
    const deployerFILL = await hre.ethers.getContractAt("DeployerFILL", DeployerFILLAddress);
    const deployerDataFetcher = await hre.ethers.getContractAt("DeployerDataFetcher", DeployerDataFetcherAddress);
    console.log("本次查询的Deployer关联地址为：")
    console.log("----------------------------");
    console.log("DeployerFILLAddress", DeployerFILLAddress);
    console.log("DeployerDataFetcherAddress", DeployerDataFetcherAddress);
    console.log("----------------------------");

    console.log("部署是否成功：", await deployerFILL.isReady());
    const addrs = await deployerFILL.getFILLAddrs();
    console.log("validation", addrs[0]);
    console.log("calculation", addrs[1]);
    console.log("filecoinAPI", addrs[2]);
    console.log("filTrust", addrs[3]);
    console.log("fitStake", addrs[4]);
    console.log("governance", addrs[5]);
    console.log("filLiquid", addrs[6]);
    console.log("filGovernance", addrs[7]);

    const addr = await deployerDataFetcher.getAddr();
    console.log("datafetcher", addr);
    const multiSignerAddrs = await deployerFILL.getMultiSignerAddrs()
    
    console.log("\nmuliSigner:");
    console.log("institutionSigner", multiSignerAddrs[0]);
    console.log("teamSigner", multiSignerAddrs[1]);
    console.log("foundationSigner", multiSignerAddrs[2]);
    console.log("reserveSigner", multiSignerAddrs[3]);
    console.log("communitySigner", multiSignerAddrs[4]);
    console.log("feeReceiverSigner", multiSignerAddrs[5]);

    const erc20Pot = await deployerFILL.getPotAddrs();
    console.log("\nERC20Pot:");
    console.log("institutionPot", erc20Pot[0]);
    console.log("teamPot", erc20Pot[1]);
    console.log("foundationPot", erc20Pot[2]);
    console.log("reservePot", erc20Pot[3]);
    console.log("communityPot", erc20Pot[4]);
    console.log("feeReceiverPot", erc20Pot[5]);

    const config_addrs = {
        "institution": [multiSignerAddrs[0], erc20Pot[0]],
        "team": [multiSignerAddrs[1], erc20Pot[1]],
        "foundation": [multiSignerAddrs[2], erc20Pot[2]],
        "reserve": [multiSignerAddrs[3], erc20Pot[3]],
        "community": [multiSignerAddrs[4], erc20Pot[4]],
        "feeReceiver": [multiSignerAddrs[5], erc20Pot[5]],
    }
    console.log("\nconfig_addrs:", JSON.stringify(config_addrs));
}



main();