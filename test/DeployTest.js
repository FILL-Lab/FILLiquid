const hre = require("hardhat");

async function main() {
  const deployerFILL = await hre.ethers.getContractAt("DeployerFILL", "0xbe230717efc8d506A225062A3840807A8BdF6f61");
  console.log(await deployerFILL.isReady());
  console.log(await deployerFILL.getFILLAddrs());
  console.log(await deployerFILL.isReady.populateTransaction());
  console.log(await deployerFILL.getFILLAddrs.populateTransaction());
  console.log(await deployerFILL.getPotAddrs())
  const pot = await hre.ethers.getContractAt("ERC20Pot", "0xd3ecE931938E6fecB08a7e2cF5CA55AE4eb847a8");
  const [signer] = await hre.ethers.getSigners();
  // const empty_tx = await signer.populateTransaction({});
  // console.log("empty_tx", empty_tx);
  // 组装消息成data
  let tx = await pot.transfer.populateTransaction("0xd3ecE931938E6fecB08a7e2cF5CA55AE4eb847a8", 100n);
  tx = await signer.populateTransaction();
  signer.getNonce().then((nonce) => {
    console.log("nonce", nonce);
  });
  // 打印 tx
  console.log("tx", tx);
  let json_tx = pot.interface.parseTransaction(tx);
  // 解析data
  console.log(json_tx.name, json_tx.args.toLocaleString());
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