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
            await this.figStake.connect(this.signer1).unstake(0)
            // this.mineBlocks(960*2)
            let timestamp = (await ethers.provider.getBlock()).timestamp
            let stake0 = this.figStake.getStakeById(0)

            console.log("timestamp: ", timestamp)
            console.log("stake0: ", stake0)

            console.log("timestamp: ", timestamp)
            await this.figStake.connect(this.figStakeFoundation).setNextBounsTimestamp(timestamp)
            console.log('parseEther("100"): ', parseEther("100").toString())
            // console.log("this.figStake.addBonus: ", this.figStake.addBonus)
            // console.log("this.figStake.connect(this.figStakeFoundation).addBonus: ", this.figStake.connect(this.figStakeFoundation).addBonus)
            const bonusAmount = 1
            await this.figStake.connect(this.figStakeFoundation).addBonus(bonusAmount, timestamp, {value: bonusAmount}) 

            const transaction = {
                to: this.figStake.target,
                value: parseEther("100")
            }
            
            // let wallet = ethers.Wallet(this.figStakeFoundation.)
            await this.figStakeFoundation.sendTransaction(transaction)

            await this.figStake.connect(this.figStakeFoundation).addBonus(parseEther("100"), {value: parseEther("100")})

            this.mineBlocks(2880 * 45)
            
            const transaction2 = {
                to: this.figStake.target,
                value: parseEther("100")
            }
            
            // let wallet = ethers.Wallet(this.figStakeFoundation.)
            await this.figStakeFoundation.sendTransaction(transaction2)


            // ("(await ethers.provider.getBalance(this.figStakeFoundation.address)).toBigInt(): ", (await ethers.provider.getBalance(this.figStakeFoundation.address)))

            console.log("await this.figStake._bonuses(): ", await this.figStake.getBonusByIndex(0))

            console.log("await this.figStake._bonuses(): ", await this.figStake.getBonusByIndex(1))

            // const result = await this.figStake.getBonusByBonusIndicesStakeIds([0], [0, 1])
            // console.log("result: ", result)

            const bonus = await this.figStake.getBonusByBonusIndexStakeId(1, 0)
            console.log("bonus: ", bonus)

            const bonus1 = await this.figStake.getBonusByBonusIndexStakeId(1, 1)
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