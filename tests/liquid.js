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
  const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { assert } = require("console")

  const parseEther = utils.parseEther
  
  
  const INIT_FEE_RATE = 100
  const INIT_MANAGER = "0xa293B3d8EF9F2318F7E316BF448e869e8833ec63"
  const FEE_RATE_TOTAL = 10000
  const MAX_COMMISSION = 500e18
  
  // const [owner] = await ethers.getSigners()
  
  // const INIT_FOUNDATION_ADDRESS = owner.address
  const INIT_MAX_DEBT_RATE = 400000
  
  // const SPex = artifacts.require('SPex')
  
  
  describe("Liquid", function () {
    async function deployLiquid() {
      console.log("has entered the deployLiquid")

      const [owner, otherAccount] = await ethers.getSigners()


      const FILTrust = await hre.ethers.getContractFactory("FILTrust");
      const filTrust = await FILTrust.deploy("FILTrust", "FIT")

      console.log("deployed filTrust")

      const Validation = await hre.ethers.getContractFactory("Validation");
      const validation = await Validation.deploy()

      
      const Stake = await hre.ethers.getContractFactory("FILStake");
      const stake = await Stake.deploy()

      const Calculation = await hre.ethers.getContractFactory("Calculation");
      const calculation = await Calculation.deploy()


      const FilecoinAPI = await hre.ethers.getContractFactory("FilecoinAPI");
      const filcoinAPI = await FilecoinAPI.deploy()


      const FILGovernance = await hre.ethers.getContractFactory("FILGovernance");
      const fILGovernance = await FILGovernance.deploy("FILGovernance", "FIG")

      console.log("deployed fILGovernance")

      const Governance = await hre.ethers.getContractFactory("Governance");
      const governance = await Governance.deploy()

      const FILLiquid = await hre.ethers.getContractFactory("FILLiquid")
      const liquid = await FILLiquid.deploy(filTrust.address, validation.address, calculation.address, filcoinAPI.address, stake.address, governance.address, owner.address, {gasLimit: 30000000})

      await governance.setContactAddrs(liquid.address, stake.address, fILGovernance.address)
      await stake.setContactAddrs(liquid.address, governance.address, filTrust.address, calculation.address, fILGovernance.address)

      filTrust.addManager(liquid.address)
      return { liquid, filTrust, validation, calculation, filcoinAPI, stake, governance, owner, otherAccount }
    }
  // function getRangeNumber(min, max) {
  //   min = BigInt(min)
  //   max = BigInt(max)
  //   num = Math.floor(BigInt(Math.random()) * (max - min + 1n)) + min;
  //   return BigInt(num)
  // }

  function getRangeNumber(min, max) { // returns BigInt 0 to (range non inclusive)
    min = BigInt(min)
    max = BigInt(max)
    if (min > max) {
      console.trace()
      throw("can not get a number in a range, beacuse min >= max")
    }
    range = max - min + 1n
    var rand = [], digits = range.toString().length / 9 + 2 | 0;
    while (digits--) { 
        rand.push(("" + (Math.random() * 1000000000 | 0)).padStart(9, "0"));
    }
    return BigInt(rand.join("")) % range + min;  // Leading zeros are ignored
  }

  // describe("Deployment", function () {
  //   it("Shold set the right foundation", async function () {
  //     const { spex, owner, otherAccount } = await loadFixture(deploySPexBeneficiary)
  //   // console.log("spex: ", spex)
  //   // console.log("owner: ", owner)
  //   // console.log("otherAccount: ", otherAccount)
  //   })
  // })

  async function checkParams(liquid, filTrust, params) {
      for (let address in params.addresses_users_map) {
          balance = await filTrust.balanceOf(address)
          balance_fit = params.addresses_users_map[address].balance_fit
          fil_balance = (await liquid.provider.getBalance(address)).toBigInt();
          await expect(balance.toBigInt()).to.equal(balance_fit)
      }
  }

  function calcutionParams() {

  }

  function getRandomUser(params) {
    userIndex = getRangeNumber(0, Object.keys(params.addresses_users_map).length-1)
    address = Object.keys(params.addresses_users_map)[userIndex]
    user = params.addresses_users_map[address]
    return user
  }

  function getRandomMiner(params) {
    index = getRangeNumber(0, Object.keys(params.id_miners_map).length-1)
    id = Object.keys(params.id_miners_map)[index]
    miner = params.id_miners_map[id]
    return miner
  }

  async function deposit(liquid, params) {
    minDepositAmount = BigInt(1e18)
    // new_deposit_fil = BigInt(1e18)

    // userIndex = getRangeNumber(0, Object.keys(params.addresses_users_map).length)
    // address = Object.keys(params.addresses_users_map)[userIndex]
    // signer = params.addresses_users_map[address].signer
    signer = getRandomUser(params).signer

    signerBalance = (await signer.provider.getBalance(signer.address)).toBigInt()
    if (signerBalance <= minDepositAmount) {
      return
    }
    new_deposit_fil = getRangeNumber(minDepositAmount, signerBalance)

    await liquid.connect(signer).deposit(1000000, {value: new_deposit_fil})
    params.cumulative_deposit_fil += new_deposit_fil
    params.liquidity_fil += new_deposit_fil
    params.fil_fit_conversion_rate = params
    params.current_balance_fil += new_deposit_fil
    if (params.supply_fit == 0n) {
      params.fil_fit_conversion_rate = 1n
    }else{
      params.fil_fit_conversion_rate = params.cumulative_liquid_fil * params.rate_base / params.supply_fit
    }

    params.addresses_users_map[signer.address].balance_fit += new_deposit_fil

  }
  async function collateralizingMiner(liquid, params) {
    minerId = getRangeNumber(100, 10000000)
    signer = getRandomUser(params).signer
    await liquid.connect(signer).collateralizingMiner(minerId, "0x12")
    params.id_miners_map[minerId] = {
      total_balance: minerId * BigInt(3e18) + (minerId * minerId),
      signer: signer,
      borrowed_amount: 0n
    }
  }
  async function borrow(liquid, params) {
    // signer = getRandomUser(params).signer
    miner = getRandomMiner(params)
    availableBorrowAmount = miner.total_balance - miner.borrowed_amount
    minBorrowAmount = 10n * BigInt(1e18)
    if(availableBorrowAmount < minBorrowAmount){
      return
    }

    maxBorrowAmount = availableBorrowAmount
    if (maxBorrowAmount > params.current_balance_fil * 900000n / 1000000n) {
      maxBorrowAmount = params.current_balance_fil * 900000n / 1000000n
    }

    if (minBorrowAmount >= maxBorrowAmount) {
      return
    }

    // console.log("maxBorrowAmount: ", maxBorrowAmount)
    // console.log("availableBorrowAmount: ", availableBorrowAmount)
    // console.log("params.current_balance_fil: ", params.current_balance_fil)

    amount = getRangeNumber(minBorrowAmount, maxBorrowAmount)
    await liquid.connect(miner.signer).borrow(minerId, amount, 600000)
    miner.borrowed_amount += amount
    params.current_balance_fil -= amount
  }
  // describe("Deposit", function () {
  //   it("Shold set the right foundation", async function () {
  //     const { liquid, filTrust, validation, calculation, filcoinAPI, stake, governance, owner, otherAccount } = await loadFixture(deployLiquid)
  //     // let { liquid, owner, otherAccount } = await deployLiquid()
  //     const minerId = 1234
  //     await liquid.collateralizingMiner(minerId, "0x")
  //     await liquid.deposit(1000000, {value: parseEther("20.32")})
  //     var result =  await liquid.borrow(minerId, BigInt(15e18), 100000)
  //     await liquid.redeem(parseEther("2"), 1000000)


  //     const balance = await filTrust.balanceOf(owner.address)
  //     console.log("balance: ", balance.toBigInt())
      
  //     last_cumulative_deposit_fil = 0n
  //     new_deposit_fil = BigInt(20e18)
  //     cumulative_deposit_fil = last_cumulative_deposit_fil += new_deposit_fil

  //     last_cumulative_borrow_fil = 0n
  //     new_borrow_fil = BigInt(20e18)
  //     cumulative_borrow_fil = last_cumulative_borrow_fil += new_borrow_fil

  //     last_cumulative_redeem_fil = 0n
  //     new_redeem_fil = 100000n
  //     cumulative_redeem_fil = last_cumulative_redeem_fil + new_redeem_fil

  //     liquidity_fil = 0n

  //     supply_fit = 0n
      
  //     const rate_base = 1000000n
  //     fil_fit_conversion_rate = 1
  //     if (supply_fit != 0) {
  //       fil_fit_conversion_rate = cumulative_liquid_fil * rate_base / supply_fit
  //     }

      
      

  //     // await liquid.getBorrowable(minerId)

  //   // console.log("spex: ", spex)
  //   // console.log("owner: ", owner)
  //   // console.log("otherAccount: ", otherAccount)
  //   })
  // })

  describe("Test flow", function () {
    it("Test all", async function () {
      const { liquid, filTrust, validation, calculation, filcoinAPI, stake, governance, owner, otherAccount } = await loadFixture(deployLiquid)
      params = {
        last_cumulative_deposit_fil: 0n,
        new_deposit_fil: BigInt(20e18),
        cumulative_deposit_fil: 0n,
        last_cumulative_borrow_fil: 0n,
        new_borrow_fil: BigInt(20e18),
        cumulative_borrow_fil: 0n,
        last_cumulative_redeem_fil: 0n,
        new_redeem_fil: 100000n,
        cumulative_liquid_fil: 0n,
        cumulative_redeem_fil: 0n,
        liquidity_fil: 0n,
        supply_fit: 0n,
        rate_base: 1000000n,
        fil_fit_conversion_rate: 1n,
        addresses_users_map: {},
        id_miners_map: {},
        current_balance_fil: 0n
      }

      signer_list = await ethers.getSigners()
      
      for (let signer of signer_list) {
        params.addresses_users_map[signer.address] = {
          balance_fil: (await signer.provider.getBalance(signer.address)).toBigInt(),
          signer,
          balance_fit: 0n
        }
      }
      blockNumber = await ethers.provider.getBlockNumber();
      console.log("blockNumber: ", blockNumber)
      await collateralizingMiner(liquid, params)
      blockNumber = await ethers.provider.getBlockNumber();
      console.log("blockNumber: ", blockNumber)
      await deposit(liquid, params)
      blockNumber = await ethers.provider.getBlockNumber();
      console.log("blockNumber: ", blockNumber)
      await borrow(liquid, params)
      blockNumber = await ethers.provider.getBlockNumber();
      block = await ethers.provider.getBlock();
      console.log("blockNumber: ", block.number)
      console.log("blockTimestamp: ", block.timestamp)
      await checkParams(liquid, filTrust, params)
      await hre.network.provider.send("hardhat_mine", ["0x3e8", "0x1e"]);
      block = await ethers.provider.getBlock()
      console.log("blockNumber: ", block.number)
      console.log("blockTimestamp: ", block.timestamp)

      await hre.network.provider.send("hardhat_mine", ["0x5dc", "0x1e"]);
      block = await ethers.provider.getBlock()
      console.log("blockNumber: ", block.number)
      console.log("blockTimestamp: ", block.timestamp) 
    })
  })
})