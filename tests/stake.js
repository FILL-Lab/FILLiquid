const {
    time,
    loadFixture,
  } = require("@nomicfoundation/hardhat-network-helpers")
  const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs")
  const { expect } = require("chai")
  const { ethers } = require("hardhat")
  const { BigNumber, BigNumberish } = require("@ethersproject/bignumber")
  const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers')
  const { Contract, parseEther, ZERO_ADDRESS } = require('ethers')
  
  
  const INIT_FEE_RATE = 100
  const INIT_MANAGER = "0xa293B3d8EF9F2318F7E316BF448e869e8833ec63"
  const FEE_RATE_TOTAL = 10000
  const MAX_COMMISSION = 500e18
  
  // const [owner] = await ethers.getSigners()
  
  // const INIT_FOUNDATION_ADDRESS = owner.address
  const INIT_MAX_DEBT_RATE = 400000
  
  // const SPex = artifacts.require('SPex')
  
  
  describe("Liquid", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deploySPexBeneficiary() {
      // const LibValidator = await ethers.getContractFactory("Validator")
      // const lib = await LibValidator.deploy()
      // await lib.deployed()
  
      // console.log("Library Address--->" + lib.address)
      const [owner, otherAccount] = await ethers.getSigners()
      const SPexBeneficiary = await hre.ethers.getContractFactory("FILStake", {
        libraries: {
          // Validator: lib.address,
        },
      })
      // const ERC20 = await hre.ethers.getContractFactory("FeedbackToken")
      const spex = await SPexBeneficiary.deploy()
      return { spex, owner, otherAccount }
    }
    
    // async function deployAndInitAMiner() {
    //     const { spex, owner, otherAccount } = await loadFixture(deploySPexBeneficiary)
        
    // }


  describe("Deployment", function () {
    it("Shold set the right foundation", async function () {
      const { spex, owner, otherAccount } = await loadFixture(deploySPexBeneficiary)
    // console.log("spex: ", spex)
    // console.log("owner: ", owner)
    // console.log("otherAccount: ", otherAccount)
    })
  })

})