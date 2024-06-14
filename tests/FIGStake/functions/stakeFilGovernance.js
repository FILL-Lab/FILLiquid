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
            this.mineBlocks(2880 * 45)
            // this.mineBlocks(960*2)

            await this.figStake.connect(this.signer1).unstake(0)

            let timestamp = (await ethers.provider.getBlock()).timestamp
            console.log("timestamp: ", timestamp)
            await this.figStake.connect(this.figStakeFoundation).setNextBounsTimestamp(timestamp)
            const bonusAmount = 100000000000000
            await this.figStake.connect(this.figStakeFoundation).addBonus(bonusAmount, timestamp, {value: bonusAmount}) 

            this.mineBlocks(2880 * 45)
            
            let timestamp2 = (await ethers.provider.getBlock()).timestamp
            await this.figStake.connect(this.figStakeFoundation).setNextBounsTimestamp(timestamp2)
            await this.figStake.connect(this.figStakeFoundation).addBonus(bonusAmount, timestamp2, {value: bonusAmount})

            console.log("await this.figStake._bonuses(): ", await this.figStake.getBonusByIndex(0))

            console.log("await this.figStake._bonuses(): ", await this.figStake.getBonusByIndex(1))

            console.log("--------------------------------")

            const bonus = await this.figStake.getBonusByBonusIndexStakeId(1, 0)
            console.log("bonus: ", bonus)

            const bonus1 = await this.figStake.getBonusByBonusIndexStakeId(1, 1)
            console.log("bonus1: ", bonus1)

            const stake = await this.figStake.getStakeById(0)
            console.log("stake: ", stake)

            const stake1 = await this.figStake.getStakeById(1)
            console.log("stake1: ", stake1)

        });
    });
}

module.exports = {
    tests,
}