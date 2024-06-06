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
  describe("handleInterest", function () {
    it("should mint amount of FIG correctly via interest", async function () {
    //   console.log("await this.filGovernance.balanceOf(this.singer2.address): ", await this.filGovernance.balanceOf(this.singer2.address))
    //   console.log("await this.filGovernance.balanceOf(this.singer3.address): ", await this.filGovernance.balanceOf(this.singer3.address))

      // let status = await this.fitStake.getStatus()
      // console.log("status: ", status)

      await this.fitStake.connect(filLiquidMockSigner).handleInterest(this.singer2.address, parseEther("12323210000"), parseEther("10000").toBigInt())
      await this.fitStake.connect(filLiquidMockSigner).handleInterest(this.singer3.address, parseEther("13443340000"), parseEther("10000").toBigInt())
      await this.fitStake.connect(filLiquidMockSigner).handleInterest(this.singer4.address, parseEther("13443340000"), this.constants.ONE_ETHER * 1000n * 1000n * 1000n)

      // let status2 = await this.fitStake.getStatus()
      // console.log("status2: ", status2)

      expect((await this.filGovernance.balanceOf(this.singer2.address)).toBigInt()).to.be.equal(277178812137240082090243n)
      expect((await this.filGovernance.balanceOf(this.singer3.address)).toBigInt()).to.be.equal(277018753608286352598908n)
      expect((await this.filGovernance.balanceOf(this.singer4.address)).toBigInt()).to.be.equal(479445802434254473565310810n)

      // console.log("await this.filGovernance.balanceOf(this.singer2.address): ", (await this.filGovernance.balanceOf(this.singer2.address)).toBigInt())
      // console.log("await this.filGovernance.balanceOf(this.singer3.address): ", (await this.filGovernance.balanceOf(this.singer3.address)).toBigInt())
      // console.log("await this.filGovernance.balanceOf(this.singer4.address): ", (await this.filGovernance.balanceOf(this.singer4.address)).toBigInt())
    })
  })
}

module.exports = {
  tests,
}
