// const { ethers } = require('ethers')
// const { Contract, utils, ZERO_ADDRESS } = require('ethers')

const { expect } = require("chai")

const { ethers } = require("hardhat");

// console.log("ethers: ", ethers)


// const parseEther = ethers.parseEther
const parseEther = ethers.parseEther



function tests() {

    // beforeEach(async function () {
        
    // })

    describe('stakeFilGovernance', function () {
        it("should deposit correctly amount of FIG", async function () {
            await this.figStake.connect(this.signer1).stake(parseEther("1000"), 10000, 1)
            await this.figStake.connect(this.signer2).stake(parseEther("2000"), 10000, 2)

            this.mineBlocks(2880)
            const transaction = {
                to: this.figStake.target,
                value: parseEther("100")
              }
            
            // let wallet = ethers.Wallet(this.figStakeFoundation.)
            await this.figStakeFoundation.sendTransaction(transaction)


            // ("(await ethers.provider.getBalance(this.figStakeFoundation.address)).toBigInt(): ", (await ethers.provider.getBalance(this.figStakeFoundation.address)))

            console.log("await this.figStake._bonuses(): ", await this.figStake.getBonusByIndex(0))

            // const result = await this.figStake.getBonusByBonusIndicesStakeIndices([0], [0, 1])
            // console.log("result: ", result)

            const bonus = await this.figStake.getBonusByBonusIndexStakeIndex(0, 0)
            console.log("bonus: ", bonus)

            const bonus1 = await this.figStake.getBonusByBonusIndexStakeIndex(0, 1)
            console.log("bonus1: ", bonus1)

            const stake = await this.figStake.getStakeByIndex(0)
            console.log("stake: ", stake)

            const stake1 = await this.figStake.getStakeByIndex(1)
            console.log("stake1: ", stake1)
        });
    });
}

module.exports = {
    tests,
}