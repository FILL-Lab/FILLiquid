const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { expect } = require("chai")

const parseEther = utils.parseEther

const DEFAULT_VOTE_THRESHOLD = parseEther("10").toBigInt();


function tests() {

    beforeEach(async function () {
        await this.governance.connect(this.signer2).propose(1, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000"), parseEther("13644919411200")])
        this.proposalId = 0


        await this.governance.connect(this.signer1).propose(1, 324n, "abc啦啦啦\ndsd单独", [parseEther("12000001"), parseEther("13644919411201")])
        this.proposalId2 = 1

        this.bondSigner = this.signer2
        this.noBondSigner = this.signer3

        const boundAmount = parseEther("2321.4")
        await this.governance.connect(this.bondSigner).bond(boundAmount)
        this.bondedAmount = boundAmount
    })

    describe('vote', function () {

        it("should revert Bonded FIG not enough", async function () {
            const promise = this.governance.connect(this.noBondSigner).vote(this.proposalId, 0, parseEther("234"))
            await expect(promise).to.be.revertedWith("Bonded FIG not enough")
        });

        it("should revert Voting amount too low", async function () {
            const promise = this.governance.connect(this.bondSigner).vote(this.proposalId, 0, DEFAULT_VOTE_THRESHOLD - 2n)
            await expect(promise).to.be.revertedWith("Voting amount too low")
        });

        it("should revert Bonded FIG not enough 2", async function () {
            const vote1Amount = parseEther("234")
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, vote1Amount)
            const vote2Amount = this.bondedAmount.toBigInt() - vote1Amount.toBigInt() + 10n
            const promise = this.governance.connect(this.noBondSigner).vote(this.proposalId, 0, vote2Amount)
            await expect(promise).to.be.revertedWith("Bonded FIG not enough")
        });

        it("should revert Proposal voting finished", async function () {
            this.mineBlocks(2880*15)
            const vote1Amount = parseEther("234")
            const promise = this.governance.connect(this.bondSigner).vote(this.proposalId, 0, vote1Amount)
            await expect(promise).to.be.revertedWith("Proposal voting finished")
        });

        it("normal tests", async function () {
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 0, parseEther("234"))
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 1, parseEther("234"))
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 2, parseEther("234"))
            await this.governance.connect(this.bondSigner).vote(this.proposalId, 3, parseEther("234"))
        });

    });
}

module.exports = {
    tests,
}