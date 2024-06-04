const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { expect } = require("chai")

const parseEther = utils.parseEther

const DEFAULT_VOTE_THRESHOLD = parseEther("10").toBigInt();


function tests() {

    beforeEach(async function () {
        const proposer = this.signer2
        await this.governance.connect(proposer).propose(1, 323n, "abc啦啦啦\ndsd单独", [parseEther("13123456"), parseEther("14644919411234")])
        this.proposalId = 0
        this.proposer = proposer

        const proposer2 = this.signer1
        await this.governance.connect(proposer2).propose(1, 324n, "abc啦啦啦\ndsd单独", [parseEther("12000001"), parseEther("13644919411201")])
        this.proposalId2 = 1
        this.proposer2 = proposer2

        this.bondSigner = this.signer2
        this.noBondSigner = this.signer3

        const boundAmount = parseEther("2321.4")
        await this.governance.connect(this.bondSigner).bond(boundAmount)
        this.bondedAmount = boundAmount

        this.bondSigner2 = this.signer2
        const boundAmount2 = parseEther("6321.4")
        await this.governance.connect(this.bondSigner2).bond(boundAmount2)
        this.bondedAmount2 = boundAmount2
    })

    describe('execute', function () {

        it("should revert Proposal voting in progress", async function () {
            await this.mineBlocks(2880*10)
            const promise = this.governance.connect(this.proposer).execute(this.proposalId)
            await expect(promise).to.be.revertedWith("Proposal voting in progress")
        });


        it("should get all deposit", async function () {
            await this.mineBlocks(2880*16)
            const balanceFigBefore = await this.filGovernance.balanceOf(this.proposer.address)
            await this.governance.connect(this.proposer).execute(this.proposalId)
            const balanceFigAfter = await this.filGovernance.balanceOf(this.proposer.address)
            const returnAmount = balanceFigAfter.toBigInt() - balanceFigBefore.toBigInt()
            expect(returnAmount).to.be.equal(parseEther("10000").toBigInt())
        });

        it("should get all deposit with other executor", async function () {
            await this.mineBlocks(2880*16)
            const balanceFigBefore = await this.filGovernance.balanceOf(this.proposer.address)
            await this.governance.connect(this.proposer2).execute(this.proposalId)
            const balanceFigAfter = await this.filGovernance.balanceOf(this.proposer.address)
            const returnAmount = balanceFigAfter.toBigInt() - balanceFigBefore.toBigInt()
            expect(returnAmount).to.be.equal(parseEther("10000").toBigInt())
        });

        it("should get 80% deposit when exceeds", async function () {
            await this.mineBlocks(2880*16)
            await this.mineBlocks(2880*16)
            const balanceFigBefore = await this.filGovernance.balanceOf(this.proposer.address)
            await this.governance.connect(this.proposer2).execute(this.proposalId)
            const balanceFigAfter = await this.filGovernance.balanceOf(this.proposer.address)
            const returnAmount = balanceFigAfter.toBigInt() - balanceFigBefore.toBigInt()
            expect(returnAmount).to.be.equal(parseEther("10000").toBigInt()/10n * 8n)
        });

        it("should get 20% deposit when exceeds", async function () {
            await this.mineBlocks(2880*16)
            await this.mineBlocks(2880*16)
            const balanceFigBefore = await this.filGovernance.balanceOf(this.proposer2.address)
            await this.governance.connect(this.proposer2).execute(this.proposalId)
            const balanceFigAfter = await this.filGovernance.balanceOf(this.proposer2.address)
            const returnAmount = balanceFigAfter.toBigInt() - balanceFigBefore.toBigInt()
            expect(returnAmount).to.be.equal(parseEther("10000").toBigInt()/10n * 2n)
        });

        it("should get can not execute when not enough vote", async function () {
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, this.bondedAmount.toBigInt()/10n*4n-10n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 0, this.bondedAmount2.toBigInt()/10n*4n)
            await this.mineBlocks(2880*16)
            const factorsBefore = await this.fitStake.getAllFactors()
            await this.governance.connect(this.proposer).execute(this.proposalId)
            const factorsAfter = await this.fitStake.getAllFactors()
            expect(factorsBefore[0]).to.be.equal(factorsAfter[0])
            expect(factorsBefore[1]).to.be.equal(factorsAfter[1])
        });

        it("should set correctly factors of FITStake after execution", async function () {
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, this.bondedAmount.toBigInt()/10n*5n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 0, this.bondedAmount2.toBigInt()/10n*4n)
            await this.mineBlocks(2880*16)

            const voteResult = await this.governance.getVoteResult(this.proposalId)
            console.log("voteResult: ", voteResult)

            const status = await this.governance.getVoteStatus(0)
            console.log("status: ", status)

            const factorsBefore = await this.fitStake.getAllFactors()
            await this.governance.connect(this.proposer).execute(this.proposalId)
            // const factorsAfter = await this.fitStake.getAllFactors()
            expect(factorsBefore[0]).to.be.equal(parseEther("13123456"))
            expect(factorsBefore[1]).to.be.equal(parseEther("14644919411234"))
        });
    });
}

module.exports = {
    tests,
}