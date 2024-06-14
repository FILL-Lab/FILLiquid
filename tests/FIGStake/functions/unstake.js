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
        it("should revert not yet due", async function () {
            const amount = parseEther("334212")
            const singer = this.signer1
            const periodIndex = 1
            await this.figStake.connect(singer).stake(amount, 10000, periodIndex);

            const period = await this.figStake.getPeriodByIndex(periodIndex)
            const blocks = period.duration / 30n
            this.mineBlocks(blocks-10)
            const promise = this.figStake.connect(singer).stake(amount, 10000, periodIndex);
            await expect(promise).to.revertedWith("not yet due")
        });

        it("should revert not staker", async function () {
            const amount = parseEther("1224")
            const singer = this.signer3
            const periodIndex = 4
            await this.figStake.connect(singer).stake(amount, 10000, periodIndex)
            
            const period = await this.figStake.getPeriodByIndex(periodIndex)
            const blocks = period.duration / 30n
            this.mineBlocks(blocks+10)
            const promise = this.figStake.connect(this.signer1).unstake(0)
            await expect(promise).to.revertedWith("not staker")
        });

        it("should receive correctly FIG", async function () {
            const amount = parseEther("1224")
            const singer = this.signer3
            const periodIndex = 4
            await this.figStake.connect(singer).stake(amount, 10000, periodIndex)
            
            const period = await this.figStake.getPeriodByIndex(periodIndex)
            const blocks = period.duration / 30n
            this.mineBlocks(blocks+10)
            const balanceBefore = await this.filGovernance.balanceOf(signer.address)
            await this.figStake.connect(singer).unstake(0)
            const balanceAfter = await this.filGovernance.balanceOf(signer.address)
            expect(balanceAfter - balanceBefore).to.equal(amount)
        });

        it("should update correctly stake info", async function () {
            const amount = parseEther("1224")
            const singer = this.signer3
            const periodIndex = 4
            await this.figStake.connect(singer).stake(amount, 10000, periodIndex)
            let timestamp = (await ethers.provider.getBlock()).timestamp

            
            const period = await this.figStake.getPeriodByIndex(periodIndex)
            const blocks = period.duration / 30n
            this.mineBlocks(blocks+10)
            await this.figStake.connect(singer).unstake(0)
            
            let timestamp1 = (await ethers.provider.getBlock()).timestamp

            const stake = await this.figStake.getStakeById(0)

            expect(stake.staker).to.equal(singer.address)
            expect(stake.amount).to.equal(amount)
            expect(stake.weight).to.equal(period.weight)
            expect(stake.stakeTimestamp).to.equal(timestamp)
            expect(stake.unlockTimestamp).to.equal(BigInt(timestamp) + period.duration)
            expect(stake.unstaked).to.equal(true)
            expect(stake.startBonusIndex).to.equal(0)
            expect(stake.unstakeTimestamp).to.equal(timestamp1)
            expect(stake.bonusNumber).to.equal(1)
            expect(stake.withdrawNumber).to.equal(0)
        });

        it("should emit correctly event", async function () {
            const amount = parseEther("1224")
            const singer = this.signer3
            const periodIndex = 4
            await this.figStake.connect(singer).stake(amount, 10000, periodIndex)
            await this.figStake.connect(this.signer1).stake(amount, 10000, periodIndex)
            
            const period = await this.figStake.getPeriodByIndex(periodIndex)
            const blocks = period.duration / 30n
            this.mineBlocks(blocks+10)
            const promise = await this.figStake.connect(singer).unstake(1)
            await expect(promise).to.emit(this.figStake, "EventStake").withArgs(1)

            const promise1 = await this.figStake.connect(singer).unstake(0)
            await expect(promise1).to.emit(this.figStake, "EventStake").withArgs(0)
        });
    });
}

module.exports = {
    tests,
}