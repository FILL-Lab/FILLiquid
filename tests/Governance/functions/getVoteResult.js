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

    describe('getVoteResult', function () {

        it("should get yes", async function () {
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, this.bondedAmount.toBigInt()/10n*5n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 0, this.bondedAmount2.toBigInt()/10n*6n)
            await this.mineBlocks(2880*16)

            const voteResult = await this.governance.getVoteResult(this.proposalId)
            expect(voteResult).to.be.equal(0)
        });

        it("should get yes 2", async function () {
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, this.bondedAmount.toBigInt()/10n*5n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 0, this.bondedAmount2.toBigInt()/10n*6n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 1, this.bondedAmount2.toBigInt()/10n*4n)
            await this.mineBlocks(2880*16)

            const voteResult = await this.governance.getVoteResult(this.proposalId)
            expect(voteResult).to.be.equal(0)
        });


        it("should get yes 3", async function () {
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, this.bondedAmount.toBigInt()/10n*5n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 0, this.bondedAmount2.toBigInt()/10n*6n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 2, this.bondedAmount2.toBigInt()/10n*4n)
            await this.mineBlocks(2880*16)

            const voteResult = await this.governance.getVoteResult(this.proposalId)
            expect(voteResult).to.be.equal(0)
        });

        it("should get yes 4", async function () {
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, this.bondedAmount.toBigInt()/10n*5n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 0, this.bondedAmount2.toBigInt()/10n*6n)
            await this.governance.connect(this.bondSigner2).vote(this.proposalId, 3, this.bondedAmount2.toBigInt()/10n*4n)
            await this.mineBlocks(2880*16)

            const voteResult = await this.governance.getVoteResult(this.proposalId)
            expect(voteResult).to.be.equal(0)
        });



        // it("should get yes", async function () {
        //     await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, this.bondedAmount.toBigInt()/10n*5n)
        //     await this.governance.connect(this.bondSigner2).vote(this.proposalId, 0, this.bondedAmount2.toBigInt()/10n*4n)
        //     await this.mineBlocks(2880*16)

        //     const voteResult = await this.governance.getVoteResult(this.proposalId)
        //     expect(voteResult).to.be.equal(0)
        // });
    });
}

module.exports = {
    tests,
}