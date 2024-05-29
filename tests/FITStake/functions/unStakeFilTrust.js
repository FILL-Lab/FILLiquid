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
  describe("unStakeFilTrust", function () {

    const STAKE_PERIOD = 2880 * 360
    const STAKE_AMOUNT = parseEther("10967").toBigInt();

    beforeEach(async function () {
      this.stakeSigner = this.singer2
      this.nonStakeSigner = this.singer3

      const transaction = await this.fitStake.connect(this.stakeSigner).stakeFilTrust(STAKE_AMOUNT, 100230000, STAKE_PERIOD)
      await transaction.wait()
      const receipt = await ethers.provider.getTransactionReceipt(transaction.hash);
      const log = receipt.logs[receipt.logs.length - 1];
      const decodedEvent = this.fitStake.interface.decodeEventLog("Staked", log.data, log.topics)
      const stakeId = decodedEvent.id.toBigInt()

      this.stakeId = stakeId
    })

    // it("Amount too small", async function () {
    //   let promise1 = this.fitStake.connect(filLiquidMockSigner).stakeFilTrust(DEFAULT_MIN_STAKE - 1n, 100, parseEther("3.2"))
    //   await expect(promise1).to.be.revertedWith("Amount too small")
    // })

    it("should revert Invalid stakeId", async function () {
      this.mineBlocks(STAKE_PERIOD)
      let promise = this.fitStake.connect(this.singer1).unStakeFilTrust(this.stakeId)
      await expect(promise).to.be.revertedWith("Invalid stakeId")
    })

    it("should get amount of FIT correctly", async function () {
      this.mineBlocks(STAKE_PERIOD*2)
      const fitBalanceBefore = await this.filTrust.balanceOf(this.stakeSigner.address)
      await this.fitStake.connect(this.stakeSigner).unStakeFilTrust(this.stakeId)
      const fitBalanceAfter = await this.filTrust.balanceOf(this.stakeSigner.address)
      expect(fitBalanceBefore.toBigInt()).to.be.equal(fitBalanceAfter.toBigInt()-STAKE_AMOUNT)
    })

    it("Should be equal before and after of non-staker", async function () {
      this.mineBlocks(STAKE_PERIOD*2)
      const fitBalanceBefore = await this.filTrust.balanceOf(this.nonStakeSigner.address)
      await this.fitStake.connect(this.stakeSigner).unStakeFilTrust(this.stakeId)
      const fitBalanceAfter = await this.filTrust.balanceOf(this.nonStakeSigner.address)
      expect(fitBalanceBefore).to.be.equal(fitBalanceAfter)
    })

    it("should get amount of FIT correctly when deposit not withdrawn at maturity", async function () {
      this.mineBlocks(STAKE_PERIOD*3)
      await this.fitStake.connect(this.stakeSigner).unStakeFilTrust(this.stakeId)
      await this.fitStake.connect(this.stakeSigner).withdrawFIG(this.stakeId)
      const balanceFIG = await this.filGovernance.balanceOf(this.stakeSigner.address)
      console.log("balanceFIG.toBigInt(): ", balanceFIG.toBigInt())
      // expect(balanceFIG.toBigInt()).to.be.equal(fitBalanceAfter.toBigInt()-STAKE_AMOUNT)
    })
  })
}

module.exports = {
  tests,
}
