const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { expect } = require("chai")

const parseEther = utils.parseEther


const ONE_ETHER = BigInt(1e18)

const DEFAULT_N_INTEREST = 1.2e25;
const DEFAULT_N_STAKE = 1.36449194112e31;
const DEFAULT_MIN_STAKE_PERIOD = 86400; //30 days
const DEFAULT_MAX_STAKE_PERIOD = 1036800; //360 days
const DEFAULT_MIN_STAKE = ONE_ETHER;
const DEFAULT_MAX_STAKES = 100;
const DEFAULT_RATE_BASE = 10;
const DEFAULT_INTEREST_SHARE = 4;
const DEFAULT_STAKE_SHARE = 6;


const OWNER_DEPOSIT_FIL = ONE_ETHER * 1000n;
const SIGNER1_DEPOSIT_FIL = ONE_ETHER * 5000n;
const SIGNER2_DEPOSIT_FIL = ONE_ETHER * 10000n;
const SIGNER3_DEPOSIT_FIL = ONE_ETHER * 10000n;


function tests() {

  beforeEach(async function () {
  })

  describe("stakeFilTrust", function () {

    // it("Amount too small", async function () {
    //   let promise1 = this.fitStake.connect(filLiquidMockSigner).stakeFilTrust(DEFAULT_MIN_STAKE - 1n, 100, parseEther("3.2"))
    //   await expect(promise1).to.be.revertedWith("Amount too small")
    // })

    it("Amount too small", async function () {
      let promise1 = this.fitStake.connect(this.singer1).stakeFilTrust(DEFAULT_MIN_STAKE, 1, DEFAULT_MIN_STAKE_PERIOD + 1)
      await expect(promise1).to.be.revertedWith("Block height exceeds")
    })

    it("Invalid duration", async function () {
      console.log("block.number: ", (await ethers.provider.getBlock()).number)
      let promise1 = this.fitStake.connect(filLiquidMockSigner).stakeFilTrust(DEFAULT_MIN_STAKE, 100000, DEFAULT_MIN_STAKE_PERIOD - 1)
      await expect(promise1).to.be.revertedWith("Invalid duration")

      let promise2 = this.fitStake.connect(filLiquidMockSigner).stakeFilTrust(DEFAULT_MIN_STAKE, 100000, DEFAULT_MAX_STAKE_PERIOD + 1)
      await expect(promise2).to.be.revertedWith("Invalid duration")
    })

    it("StakerStatus", async function () {
      // await this.fitStake.connect(owner).stakeFilTrust(DEFAULT_MIN_STAKE, 13332, 2880*30)
      await this.fitStake.connect(this.singer2).stakeFilTrust(ONE_ETHER * 10000n, 10003230, 2880 * 30)
      await this.fitStake.connect(this.singer3).stakeFilTrust(ONE_ETHER * 10000n, 10000434, 2880 * 30)

      let stakerStatus = await this.fitStake.getStakerStakes(this.singer2.address)
      // console.log("stakerStatus: ", stakerStatus)

      // expect(stakerStatus.stakeSum).to.be.equal(1200)
      // expect(stakerStatus.totalFIGSum).to.be.equal(0)
      // expect(stakerStatus.releasedFIGSum).to.be.equal(0)
      // expect(stakerStatus.Stake.length).to.be.equal(2)

    })


    it("should mint amount of FIG correctly via stake FIT", async function () {
      // console.log("await this.filGovernance.balanceOf(this.singer2.address): ", await this.filGovernance.balanceOf(this.singer2.address))
      // console.log("await this.filGovernance.balanceOf(this.singer3.address): ", await this.filGovernance.balanceOf(this.singer3.address))

      const transaction = await this.fitStake.connect(this.singer2).stakeFilTrust(parseEther("10967"), 100230000, 2880 * 360)
      await transaction.wait()
      const receipt = await ethers.provider.getTransactionReceipt(transaction.hash);
      const log = receipt.logs[receipt.logs.length - 1];
      const decodedEvent = this.fitStake.interface.decodeEventLog("Staked", log.data, log.topics)
      const stakeId = decodedEvent.id.toBigInt()
      const stakeInfo = await this.fitStake.getStakeInfoById(stakeId)
      expect(stakeInfo.stake.totalFIG).to.be.equal(415761617412233941570777n)
      // console.log("stakeInfo: ", stakeInfo)
      // console.log("stakeInfo.stake.totalFIG: ", stakeInfo.stake.totalFIG)

      const transaction2 = await this.fitStake.connect(this.singer3).stakeFilTrust(parseEther("10967"), 100230000, 2880 * 360)
      await transaction2.wait()
      const receipt2 = await ethers.provider.getTransactionReceipt(transaction2.hash);
      const log2 = receipt2.logs[receipt2.logs.length - 1];
      const decodedEvent2 = this.fitStake.interface.decodeEventLog("Staked", log2.data, log2.topics)
      const stakeId2 = decodedEvent2.id.toBigInt()
      const stakeInfo2 = await this.fitStake.getStakeInfoById(stakeId2)
      expect(stakeInfo2.stake.totalFIG).to.be.equal(415521537242077354079600n)

      // console.log("this.filGovernance: ", this.filGovernance)
      // expect(await this.filGovernance.balanceOf(this.singer2.address)).to.be.equal(parseEther("415768"))
      // expect(await this.filGovernance.balanceOf(this.singer3.address)).to.be.equal(parseEther("277019"))

      // let status = await this.fitStake.getStatus()
      // console.log("status: ", status)

      // console.log("await this.filGovernance.balanceOf(this.singer2.address): ", (await this.filGovernance.balanceOf(this.singer2.address)).toBigInt())
      // console.log("await this.filGovernance.balanceOf(this.singer3.address): ", (await this.filGovernance.balanceOf(this.singer3.address)).toBigInt())
      // console.log("await this.filGovernance.balanceOf(this.singer4.address): ", (await this.filGovernance.balanceOf(this.singer4.address)).toBigInt())


    })



    it("should mint amount of FIG correctly via stake huge FIT", async function () {
      const depositSigner = this.singer4
      // const depositAmount = parseEther("10000000000")
      const depositAmount = parseEther("13160609")

      await filLiquid.connect(depositSigner).deposit(depositAmount, { value: depositAmount })

      const transaction = await this.fitStake.connect(depositSigner).stakeFilTrust(depositAmount, 100230000, 2880 * 360)
      await transaction.wait()
      const receipt = await ethers.provider.getTransactionReceipt(transaction.hash);
      const log = receipt.logs[receipt.logs.length - 1];
      const decodedEvent = this.fitStake.interface.decodeEventLog("Staked", log.data, log.topics)
      const stakeId = decodedEvent.id.toBigInt()
      const stakeInfo = await this.fitStake.getStakeInfoById(stakeId)
      expect(stakeInfo.stake.totalFIG).to.be.equal(360000000000000000000000000n)

    })
  })
}

module.exports = {
  tests,
}
