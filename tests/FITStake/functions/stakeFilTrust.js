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
  describe("stakeFilTrust", function () {

    it("Amount too small", async function () {
      let promise1 = this.fitStake.connect(filLiquidMockSigner).stakeFilTrust(DEFAULT_MIN_STAKE - 1n, 100, parseEther("3.2"))
      await expect(promise1).to.be.revertedWith("Amount too small")
    })

    it("Block height exceeds", async function () {
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


    it("Normal tests", async function () {
      await this.fitStake.connect(filLiquidMockSigner).handleInterest(this.singer1.address, parseEther("143.2"), 2880 * 30)

    })
  })
}

module.exports = {
  tests,
}