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
const { transaction } = require("@openzeppelin/test-helpers/src/send")
const { duration } = require("@openzeppelin/test-helpers/src/time")

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

      await fILGovernance.addManager(liquid.address)
      await fILGovernance.addManager(stake.address)
      await filTrust.addManager(liquid.address)

      return { liquid, filTrust, validation, calculation, filcoinAPI, stake, governance, owner, otherAccount }
    }
  function getRangeNumber2(min, max) {
    num = Math.floor(Math.random() * (max - min + 1)) + min;
    return num
  }

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
    console.log("enter function checkParams")

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
    console.log("enter function deposit")

    minDepositAmount = BigInt(1e18)

    // new_deposit_fil = BigInt(1e18)

    // userIndex = getRangeNumber(0, Object.keys(params.addresses_users_map).length)
    // address = Object.keys(params.addresses_users_map)[userIndex]
    // signer = params.addresses_users_map[address].signer
    user = getRandomUser(params)
    signer = user.signer

    signerBalance = (await ethers.provider.getBalance(signer.address)).toBigInt()
    if (signerBalance <= minDepositAmount) {
      return
    }
    new_deposit_fil = getRangeNumber(minDepositAmount, signerBalance)

    tx = await liquid.connect(signer).deposit(0, {value: new_deposit_fil})
    result = await tx.wait()
    user.balance_fil -= result.cumulativeGasUsed.toBigInt() * result.effectiveGasPrice.toBigInt()

    exchangeRateDeposit = (await liquid.exchangeRateDeposit(new_deposit_fil)).toBigInt()
    console.log("exchangeRateDeposit: ", exchangeRateDeposit)

    
    mu = Math.pow((1 - 0.9) / (1 - u), (u - 0.9) * 2.5)

    params.cumulative_deposit_fil += new_deposit_fil
    params.current_balance_fil += new_deposit_fil
    if (params.supply_fit == 0n) {
      params.fil_fit_conversion_rate = params.rate_base
    }else{
      params.fil_fit_conversion_rate = params.liquidity_fil * params.rate_base / params.supply_fit
    }
    mintFit = new_deposit_fil * params.rate_base / params.fil_fit_conversion_rate
    params.addresses_users_map[signer.address].balance_fit += mintFit

    console.log("deposit signer.address: ", signer.address, "value: ", new_deposit_fil, "params.fil_fit_conversion_rate: ", params.fil_fit_conversion_rate, "params.liquidity_fil: ", params.liquidity_fil, "params.supply_fit: ", params.supply_fit, "mintFit: ", mintFit)
    params.liquidity_fil += new_deposit_fil
    params.supply_fit += mintFit
  }


  async function collateralizingMiner(liquid, params) {
    console.log("enter function collateralizingMiner")
    minerId = getRangeNumber(100, 10000000)
    user = getRandomUser(params)
    signer = user.signer
    if (params.address_miner_id_list_map[signer.address] && params.address_miner_id_list_map[signer.address].length >=5 ) {
      return
    }
    // console.log("signer: ", signer, "minerId: ", minerId)
    // beforeBalance = (await ethers.provider.getBalance(signer.address)).toBigInt()
    tx = await liquid.connect(signer).collateralizingMiner(minerId, "0x12")
    console.log("liquid.connect(signer).collateralizingMiner", "signer.address: ", signer.address, "minerId: ", minerId)
    // afterBalance = (await ethers.provider.getBalance(signer.address)).toBigInt()
    result = await tx.wait()
    user.balance_fil -= result.cumulativeGasUsed.toBigInt() * result.effectiveGasPrice.toBigInt()

    // console.log("gasUsed: ", result.gasUsed.toBigInt(), "cumulativeGasUsed: ", result.cumulativeGasUsed.toBigInt(), "effectiveGasPrice: ", result.effectiveGasPrice.toBigInt(), "beforeBalance: ", beforeBalance, "afterBalance: ", afterBalance)

    params.id_miners_map[minerId] = {
      minerId: minerId,
      total_balance_fil: minerId * BigInt(3e18) + (minerId * minerId),
      signer: signer,
      user: user,
      borrowed_amount: 0n
    }
    // if (params.address_miner_number_map[signer.address] == undefined) {
    //   params.address_miner_number_map[signer.address] = 0
    // }

    if (params.address_miner_id_list_map[signer.address] == undefined) {
      params.address_miner_id_list_map[signer.address] = []
    }
    // params.address_miner_number_map[signer.address] += 1
    params.address_miner_id_list_map[signer.address].push(minerId)
  }

  async function borrow(liquid, params) {
    console.log("enter function borrow")
    // console.log("params: ", params)
    // signer = getRandomUser(params).signer
    if (Object.keys(params.id_miners_map).length == 0) {
      return
    }
    miner = getRandomMiner(params)
    // if (params.miner_id_borrow_info_map[miner.minerId]) {
    //   console.log("params.miner_id_borrow_info_map[miner.minerId].length: ", params.miner_id_borrow_info_map[miner.minerId].length)
    // }
    if (params.miner_id_borrow_info_map[miner.minerId] && params.miner_id_borrow_info_map[miner.minerId].length >= 3) {
      return
    }
    if (params.miner_id_borrow_info_map[miner.minerId] && params.miner_id_borrow_info_map[miner.minerId].length == 0) {
      return
    }

    block = await ethers.provider.getBlock()

    principalInterectList = []
    principalInterectSum = 0n
    familyBalanceSum = 0n

    for (let familyMinerId of params.address_miner_id_list_map[params.id_miners_map[miner.minerId].signer.address]){
      console.log("familyMinerId: ", familyMinerId, "params.id_miners_map[familyMinerId].balance_fil: ", params.id_miners_map[familyMinerId].balance_fil, "params.id_miners_map[familyMinerId]: ", params.id_miners_map[familyMinerId])
      familyBalanceSum += params.id_miners_map[familyMinerId].total_balance_fil
      if (!params.miner_id_borrow_info_map[familyMinerId]) {
        continue
      }
      // console.log("params.miner_id_borrow_info_map[familyMinerId]: ", params.miner_id_borrow_info_map[familyMinerId])
      for (let borrowInfo of params.miner_id_borrow_info_map[familyMinerId]) {
        durationTime = block.timestamp - borrowInfo.block.timestamp
        // principalInterect = calculatePrincipalInterect(borrowInfo.amount, durationTime, borrowInfo.interestRate, params.rate_base)

        // console.log("await ethers.provider.getBlock().timestamp: ", (await ethers.provider.getBlock()).timestamp)
        // await ethers.provider.send("evm_setNextBlockTimestamp", [block.timestamp]);
        // principalInterect = (await liquid.callStatic.paybackAmount(borrowInfo.amount, durationTime, borrowInfo.interestRate)).toBigInt()

        principalInterect = (await liquid.paybackAmount(borrowInfo.amount, durationTime, borrowInfo.interestRate)).toBigInt()

        principalInterectList.push(principalInterect)
        principalInterectSum += principalInterect
      }
    }
    minBorrowAmount = 10n * BigInt(1e18)

    console.log("familyBalanceSum: ", familyBalanceSum, "principalInterectSum: ", principalInterectSum, "principalInterectList: ", principalInterectList)

    availableBorrowAmount = familyBalanceSum - (principalInterectSum * 2n)
    if (availableBorrowAmount < minBorrowAmount) {
      return
    }


    // availableBorrowAmount = miner.total_balance_fil - miner.borrowed_amount

    maxBorrowAmount = availableBorrowAmount



    utilizationMaxAmount = params.liquidity_fil / 10n * 9n
    // utilizationMaxAmount - params.current_balance_fil

    utilizationAmount = params.liquidity_fil - params.current_balance_fil

    liquidMaxBorrowAmount = utilizationMaxAmount - utilizationAmount

    if (maxBorrowAmount > liquidMaxBorrowAmount) {
      maxBorrowAmount = liquidMaxBorrowAmount
    }

    if(maxBorrowAmount < minBorrowAmount){
      return
    }

    console.log("utilizationMaxAmount: ", utilizationMaxAmount, "utilizationAmount: ", utilizationAmount, "liquidMaxBorrowAmount: ", liquidMaxBorrowAmount, "params.current_balance_fil: ", params.current_balance_fil,  "params.liquidity_fil: ", params.liquidity_fil)


    tx = await liquid.callStatic.maxBorrowAllowed(miner.minerId)
    
    // await tx.wait()
    console.log("maxBorrowAllowed: ", tx.toBigInt())

    tx = await liquid.callStatic.getFamilyStatus(params.id_miners_map[miner.minerId].signer.address)
    console.log("getFamilyStatus: ", tx)

    // tx = await liquid.callStatic.maxBorrowAllowedByFamilyStatus(tx)
    // console.log("maxBorrowAllowedByFamilyStatus: ", tx)

    // tx = await liquid.callStatic.minerBorrows(miner.minerId)
    // console.log("minerBorrows: ", tx)

    getMinerBorrowsLength = await liquid.getMinerBorrowsLength(miner.minerId)
    console.log("getMinerBorrowsLength: ", getMinerBorrowsLength)

    amount = getRangeNumber(minBorrowAmount, maxBorrowAmount)
    console.log("signer: ", miner.signer.address, "miner.minerId: ", miner.minerId, "amount: ", amount)

    length = await liquid.getMinerBorrowsLength(miner.minerId)
    console.log("length: ", length)


    // console.log("await ethers.provider.getBlock().timestamp: ", (await ethers.provider.getBlock()).timestamp)
    // await ethers.provider.send("evm_setNextBlockTimestamp", [block.timestamp]);
    tx = await liquid.connect(miner.signer).borrow(miner.minerId, amount, 600000)
    result = await tx.wait()

    // console.log("await ethers.provider.getBlock().timestamp: ", (await ethers.provider.getBlock()).timestamp)
    miner.user.balance_fil -= result.cumulativeGasUsed.toBigInt() * result.effectiveGasPrice.toBigInt()

    console.log("borrow: ", miner.minerId, amount, 600000)

    // actualAmount, feeAmount = calculateFee(amount, 10000n)
    miner.borrowed_amount += amount
    params.current_balance_fil -= amount

    u = (params.liquidity_fil - params.current_balance_fil) * params.rate_base / params.liquidity_fil
    console.log("u: ", u, "amount: ", amount, "params.current_balance_fil: ", params.current_balance_fil,  "params.liquidity_fil: ", params.liquidity_fil)
    interestRate = (10000n + 180000n) * u / params.rate_base
    if (u > (params.rate_base / 2n)) {
      uFloat = Number(u) / Number(params.rate_base)
      base = (1 - 0.5) / (1 - 0.9)
      number = (0.6 / 0.1)
      n = Math.log(number) / Math.log(base)
      r = 0.1 * Math.pow((1 - 0.5) / (1 - uFloat), n)
      interestRate = BigInt(Math.floor(r * Number(params.rate_base)))
    }

    console.log("u: ", u, "interestRate: ", interestRate)

    block = await ethers.provider.getBlock()

    borrowInfo = {
      minerId: miner.minerId,
      amount: amount,
      interestRate: interestRate,
      block: block
    }
    // if (!Object.keys(params.miner_id_borrow_info_map).includes(miner.minerId)) {
    //   params.miner_id_borrow_info_map[miner.minerId] = []
    // }
    if (params.miner_id_borrow_info_map[miner.minerId] == undefined) {
      params.miner_id_borrow_info_map[miner.minerId] = []
    }
    params.miner_id_borrow_info_map[miner.minerId].push(borrowInfo)
    params.miner_id_borrow_info_map[miner.minerId].sort((a, b) => a.interestRate < b.interestRate ? 1 : -1)


  }

  async function hardhatMine() {
    // num = getRangeNumber2(0, 28800000)
    num = getRangeNumber2(0, 100)
    const hexadecimalNumber = num.toString(16);
    const hexStr = `0x${hexadecimalNumber}`
    await hre.network.provider.send("hardhat_mine", [hexStr, "0x1e"]);

  }

  function calculatePrincipalInterect(principal, duration, annualRate, baseRate) {
    annualRateFloat = Number(annualRate) / Number(baseRate)
    exponent = Number(duration) * Number(annualRateFloat) / 31536000
    console.log("exponent: ", exponent)
    console.log(principal, duration, annualRate, baseRate)
    return BigInt(Math.floor(Math.exp(exponent) * Number(principal)))
    // exponent = duration * annualRate * (BigInt(1e18) / baseRate) / 31536000n
    // BigInt(Math.floor(Math.exp(Number(exponent)))) * principal / BigInt(1e18)
  }

  async function directPayback(liquid, params) {
    console.log("enter function directPayback")

    if(Object.keys(params.miner_id_borrow_info_map).length == 0){
      console.log("directPayback return")
      return
    }
    index = getRangeNumber(0, Object.keys(params.miner_id_borrow_info_map).length-1)
    minerId = Object.keys(params.miner_id_borrow_info_map)[index]
    borrowInfoList = params.miner_id_borrow_info_map[minerId]
    console.log("borrowInfoList: ", borrowInfoList)

    if (params.miner_id_borrow_info_map[minerId] == 0) {
      console.log("miner_id_borrow_info_map[minerId] == 0 return")
      return
    }

    sumOfprincipal = borrowInfoList.reduce((acc, obj) => acc + obj.amount, 0n)
    console.log("sumOfprincipal: ", sumOfprincipal)

    block = await ethers.provider.getBlock()

    principalInterectList = []
    principalInterectSum = 0n

    for (let borrowInfo of borrowInfoList) {
      durationTime = block.timestamp - borrowInfo.block.timestamp
      console.log("block.timstamp: ", block.timestamp, "borrowInfo.block.timestamp: ", borrowInfo.block.timestamp)
      // principalInterect = calculatePrincipalInterect(borrowInfo.amount, durationTime, borrowInfo.interestRate, params.rate_base)
      // principalInterect = liquid.callStatic.paybackAmount(borrowInfo.amount, durationTime, borrowInfo.interestRate)

      principalInterect = (await liquid.paybackAmount(borrowInfo.amount, durationTime, borrowInfo.interestRate)).toBigInt()

      principalInterectList.push(principalInterect)
      principalInterectSum += principalInterect

      paybackAmount = await liquid.paybackAmount(borrowInfo.amount, durationTime, borrowInfo.interestRate)
      console.log("paybackAmount: ", paybackAmount)
    }
    

    miner = params.id_miners_map[minerId]

    minerSignerBalance = (await liquid.provider.getBalance(miner.signer.address)).toBigInt()
    max = minerSignerBalance
    
    // max = max > principalInterectSum ? max : principalInterectSum

    tx = await liquid.callStatic.minerBorrows(miner.minerId)
    console.log("minerBorrows: ", tx)

    paybackAmount = getRangeNumber(1n, max)
    console.log("minerId: ", minerId)

    getMinerBorrowsLength = await liquid.getMinerBorrowsLength(miner.minerId)
    console.log("getMinerBorrowsLength: ", getMinerBorrowsLength)

    console.log("await ethers.provider.getBlock().timestamp: ", (await ethers.provider.getBlock()).timestamp)

    tx = await liquid.connect(miner.signer).directPayback(minerId, {value: paybackAmount})
    console.log("directPayback", "miner.signer.address: ", miner.signer.address, "minerId: ", minerId, "paybackAmount: ", paybackAmount)
    result = await tx.wait()
    miner.user.balance_fil -= result.cumulativeGasUsed.toBigInt() * result.effectiveGasPrice.toBigInt()

    remainingAmount = paybackAmount
    interestSum = 0n
    for (let i=borrowInfoList.length-1; i>=0; i--) {
      borrowInfo = borrowInfoList[i]
      interest = principalInterectList[i] - borrowInfo.amount
      interestSum += interest
      if (principalInterectList[i] < remainingAmount) {
        console.log("pop", "i: ", i)
        borrowInfoList.pop()
        remainingAmount -= principalInterectList[i]
      }else{
        borrowInfo.amount -= remainingAmount
        borrowInfo.block = block
        remainingAmount = 0n
        break
      }
    }
    console.log("remainingAmount: ", remainingAmount, "principalInterectList: ", principalInterectList)
    actualRepayAmount = (paybackAmount - remainingAmount)
    miner.user.balance_fil -= actualRepayAmount
    params.current_balance_fil += actualRepayAmount
    params.liquidity_fil += interestSum
  }

  function calculateFee(amount , rate_base) {
    commisionFee = amount * 10000n / rate_base
    if ((amount * 10000n) % rate_base != 0) {
      commisionFee += 1
    }
    if (commisionFee > amount) {
      throw("commisionFee > amount")
    }
    return (amount - commisionFee, commisionFee)
  }

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
        current_balance_fil: 0n,
        miner_id_borrow_info_map: {},
        address_miner_id_list_map: {}
      }

      signer_list = await ethers.getSigners()
      
      for (let signer of signer_list) {
        params.addresses_users_map[signer.address] = {
          balance_fil: (await ethers.provider.getBalance(signer.address)).toBigInt(),
          signer,
          balance_fit: 0n
        }
      }

      sender = signer_list[0]

      for (let i=0; i<100; i++) {
        wallet = ethers.Wallet.createRandom()
        signer = wallet.connect(ethers.provider)
        min = BigInt(10e18)
        max = (await ethers.provider.getBalance(sender.address)).toBigInt()
        max -= BigInt(1e18)
        if (max <= min) {
          break
        }
        amount = getRangeNumber(min, max)
        // console.log("transaction: ", transaction)
        // console.log("to: ", to)
        // console.log("value: ", value)
        sendTransaction = {
          to: signer.address,
          value: amount
        }

        await sender.sendTransaction(sendTransaction)

        params.addresses_users_map[signer.address] = {
          balance_fil: (await ethers.provider.getBalance(signer.address)).toBigInt(),
          signer,
          balance_fit: 0n
        }
      }

      // _owner = await liquid._owner()
      // console.log("_owner: ", _owner)
      // return

      functionList = [collateralizingMiner, deposit, borrow, directPayback]
      // await deposit(liquid, params)
      for (let i=0; i<100; i++) {
        // await directPayback(liquid, params)


        functionIndex = getRangeNumber2(0, functionList.length - 1)

        const blockNumber = await liquid.provider.getBlockNumber();
        console.log("i: ", i, "blockNumber: ", blockNumber, "functionName: ", functionList[functionIndex].name, "----------------------------------------")


        // promise = functionList[functionIndex](liquid, params)
        // await promise

        // await hardhatMine()

        try{
          // functionList[functionIndex](liquid, params)
          // const blockNumber = await liquid.provider.getBlockNumber();
          // console.log("i: ", i, "blockNumber: ", blockNumber, "functionName: ", functionList[functionIndex].name)
          // await collateralizingMiner(liquid, params)
          // await deposit(liquid, params)
          // await borrow(liquid, params)

          if (functionIndex == 0) {
            await collateralizingMiner(liquid, params)
            console.log("end collateralizingMiner")
          }else if (functionIndex == 1) {
            await deposit(liquid, params)
            console.log("end deposit")
          }else if (functionIndex == 2) {
            await borrow(liquid, params)
            console.log("end borrow")
          }else if (functionIndex == 3) {
            await directPayback(liquid, params)
            console.log("end directPayback")
          }else {
            throw("Unknown functionIndex")
          }
          // await checkParams(liquid, filTrust, params)
          await checkParams(liquid, filTrust, params)
          console.log("end checkParams")
          await hardhatMine()
        }catch(error){
          console.log("params: ", params)
          console.log("error: ", error)
          // console.log("totalFILLiquidity: ", await liquid.totalFILLiquidity())
          // console.log("maxBorrowAllowedByUtilization: ", await liquid.maxBorrowAllowedByUtilization())
          break
        }
      }
      // console.log("params: ", params)
      // console.log("totalFILLiquidity: ", await liquid.totalFILLiquidity())
    })
  })
})