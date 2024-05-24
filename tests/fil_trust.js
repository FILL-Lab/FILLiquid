const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FILTrust", function () {
  let FILTrust, filTrust, owner, addr1, addr2, addr3;

  beforeEach(async function () {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
    FILTrust = await ethers.getContractFactory("FILTrust");
    filTrust = await FILTrust.deploy("FILTrust Token", "FTT");
    await filTrust.deployed();
  });

  it("Should add a new manager", async function () {
    await filTrust.addManager(addr1.address);
    expect(await filTrust.verifyManager(addr1.address)).to.be.true;
  });

  it("Should remove an existing manager", async function () {
    await filTrust.addManager(addr1.address);
    await filTrust.removeManager(addr1.address);
    expect(await filTrust.verifyManager(addr1.address)).to.be.false;
  });

  it("Should not remove a non-existent manager", async function () {
    await expect(filTrust.removeManager(addr1.address)).to.emit(filTrust, "ManagerRemoved").withArgs(addr1.address);
    expect(await filTrust.verifyManager(addr1.address)).to.be.false;
  });

  it("Should not add the same manager twice", async function () {
    await filTrust.addManager(addr1.address);
    await expect(filTrust.addManager(addr1.address)).to.emit(filTrust, "ManagerAdded").withArgs(addr1.address);
    expect(await filTrust.verifyManager(addr1.address)).to.be.true;
  });

  it("Should only allow the owner to add or remove managers", async function () {
    await expect(filTrust.connect(addr1).addManager(addr2.address)).to.be.revertedWith("Only owner allowed");
    await filTrust.addManager(addr1.address);
    await expect(filTrust.connect(addr1).removeManager(addr2.address)).to.be.revertedWith("Only owner allowed");
  });

  it("Test transfer", async function () {
    await filTrust.addManager(addr1.address);
    block = await ethers.provider.getBlock()
    console.log("block.number: ", block.number)
    lastMintHeight = await filTrust.lastMintHeight("0x0000000000000000000000000000000000000000")
    console.log("lastMintHeight: ", lastMintHeight)

    console.log("block.number: ", (await ethers.provider.getBlock()).number)

    mineBlockNumberHex = `0x${(8887).toString(16)}`
    await hre.network.provider.send("hardhat_mine", [mineBlockNumberHex, "0x1"]);

    // isManager = await filTrust.verifyManager(addr1.address)
    // console.log("isManager: ", isManager)

    await filTrust.connect(addr1).mint(addr2.address, 1000);
    await filTrust.connect(addr1).mint(addr2.address, 2000);

    mineBlockNumberHex = `0x${(3000).toString(16)}`
    await hre.network.provider.send("hardhat_mine", [mineBlockNumberHex, "0x1"]);

    await filTrust.connect(addr2).transfer(addr3.address, 100);



    // await filTrust.addManager(owner.address)
    // await filTrust.setOwner("0x0000000000000000000000000000000000000001")
    // await filTrust.mint(owner.address, 1000);



    // await filTrust.connect(addr1).mint(addr2.address, 2000);
    // block = await ethers.provider.getBlock()
    // console.log("block.number: ", block.number)
    // await filTrust.connect(addr2).transfer(addr1.address, 100);
    // await filTrust.connect(addr2).transfer(addr1.address, 200);
  });

});