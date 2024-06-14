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

    describe('stake', function () {
        it("should storage correctly stake info", async function () {
            const amount = parseEther("334212")
            const singer = this.signer1
            const periodIndex = 1
            await this.figStake.connect(singer).stake(amount, 10000, periodIndex);

            let timestamp = (await ethers.provider.getBlock()).timestamp

            const stake = await this.figStake.getStakeById(0)
            const period = await this.figStake.getPeriodByIndex(periodIndex)

            expect(stake.staker).to.equal(singer.address)
            expect(stake.amount).to.equal(amount)
            expect(stake.weight).to.equal(period.weight)
            expect(stake.stakeTimestamp).to.equal(timestamp)
            expect(stake.unlockTimestamp).to.equal(BigInt(timestamp) + period.duration)
            expect(stake.unstaked).to.equal(false)
            expect(stake.startBonusIndex).to.equal(0)
            expect(stake.unstakeTimestamp).to.equal(0)
            expect(stake.bonusNumber).to.equal(0)
            expect(stake.withdrawNumber).to.equal(0)
        });
        it("should storage correctly stake info 1", async function () {
            const amount = parseEther("1224")
            const singer = this.signer3
            const periodIndex = 4
            await this.figStake.connect(singer).stake(amount, 10000, periodIndex);
            // console.log("transaction: ", transaction)
            // result = await transaction.wait()
            // console.log("result: ", result)

            let timestamp = (await ethers.provider.getBlock()).timestamp
            console.log("timestamp: ", timestamp)

            const stake = await this.figStake.getStakeById(0)
            const period = await this.figStake.getPeriodByIndex(periodIndex)

            // address staker;
            // uint amount;
            // uint weight;
            // uint startBonusIndex;
            // uint stakeTimestamp;
            // uint unlockTimestamp;
            // bool unstaked;
            // uint unstakeTimestamp;
            // uint bonusNumber;
            // uint withdrawNumber;

            expect(stake.staker).to.equal(singer.address)
            expect(stake.amount).to.equal(amount)
            expect(stake.weight).to.equal(period.weight)
            expect(stake.stakeTimestamp).to.equal(timestamp)
            expect(stake.unlockTimestamp).to.equal(BigInt(timestamp) + period.duration)
            expect(stake.unstaked).to.equal(false)
            expect(stake.startBonusIndex).to.equal(0)
            expect(stake.unstakeTimestamp).to.equal(0)
            expect(stake.bonusNumber).to.equal(0)
            expect(stake.withdrawNumber).to.equal(0)
        });

        it("should emit correctly event", async function () {
            const amount = parseEther("1224")
            const singer = this.signer3
            const periodIndex = 4
            const promise = this.figStake.connect(singer).stake(amount, 10000, periodIndex);
            await expect(promise).to.emit(this.figStake, "EventStake").withArgs(0)
            const promise1 = this.figStake.connect(singer).stake(amount, 10000, periodIndex);
            await expect(promise1).to.emit(this.figStake, "EventStake").withArgs(1)
        });
    });
}

module.exports = {
    tests,
}