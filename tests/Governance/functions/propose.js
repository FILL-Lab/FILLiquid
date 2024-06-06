const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { expect } = require("chai")

const parseEther = utils.parseEther


function tests() {

    beforeEach(async function () {
        // await this.fitStake.connect(this.filLiquidMockSigner).handleInterest(this.signer1.address, parseEther("12323210000"), parseEther("10000").toBigInt())
        // await this.fitStake.connect(this.filLiquidMockSigner).handleInterest(this.signer2.address, parseEther("12323210000"), parseEther("10000").toBigInt())

        // const boundAmount = parseEther("100000")
        // await this.governance.connect(this.signer1).bond(boundAmount)
        // await this.governance.connect(this.signer2).bond(boundAmount)
        // this.bondedAmount = boundAmount
    })

    describe('propose', function () {

        it("should revert not bond", async function () {
            const ownerBoundAmount = await this.governance.bondedAmount(this.owner.address)
            console.log("ownerBoundAmount: ", ownerBoundAmount)

            console.log("this.governance.propose: ", this.governance.propose)
            await this.governance.propose(0, 323n, "abc啦啦啦\ndsd单独", [500000n, 10000n, 100000n, 600000n, 500000n, 5n, 750000n, 850000n, 10n, 43200n, 900000n, 70000n, 5n, parseEther("10"), parseEther("1")])
            // console.log("transaction: ", transaction)

            const signer4BoundAmount = await this.governance.bondedAmount(this.signer4.address)
            console.log("signer4BoundAmount: ", signer4BoundAmount)

            // await this.governance.connect(this.signer2).propose(0, 323n, "abc啦啦啦\ndsd单独", [500000n,10000n,100000n,600000n,500000n,5n,750000n,850000n,10n,43200n,900000n,70000n,5n,parseEther("10"),parseEther("1")])

            // await expect(this.governance.propose(0, 323, "abc啦啦啦\ndsd单独", [2,34])).to.be.revertedWith("not approve")
        });

        it("should revert length of values error when I propose a FILLiquid", async function () {
            const promise = this.governance.connect(this.signer1).propose(0, 323n, "abc啦啦啦\ndsd单独", [500000n, 10000n, 100000n, 600000n, 500000n, 5n, 750000n, 850000n, 10n, 43200n, 900000n, 70000n, 5n, parseEther("10"), parseEther("1"), 3])
            await expect(promise).to.be.revertedWith("Invalid input length")
        });

        it("should revert length of values error when I propose a FILLiquid 2", async function () {
            const promise = this.governance.connect(this.signer1).propose(0, 323n, "abc啦啦啦\ndsd单独", [500000n, 10000n, 100000n, 600000n, 500000n, 5n, 750000n, 850000n, 10n, 43200n, 900000n, 70000n, 5n, parseEther("10")])
            await expect(promise).to.be.revertedWith("Invalid input length")
        });


        // uint constant DEFAULT_N_INTEREST = 1.2e25;
        // uint constant DEFAULT_N_STAKE = 1.36449194112e31;

        it("should revert length of values error when propose a FITStake", async function () {
            const promise = this.governance.connect(this.signer1).propose(2, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000")])
            await expect(promise).to.be.revertedWith("Invalid input length")
        });

        it("should revert length of values error when propose a FITStake 2", async function () {
            const promise = this.governance.connect(this.signer1).propose(2, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000"), parseEther("13644919411200"), 23n])
            await expect(promise).to.be.revertedWith("Invalid input length")
        });

        it("should revert length of text exceeds MAX LENGTH", async function () {
            const text = "abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦"

            const promise = this.governance.connect(this.signer1).propose(1, 323n, text, [parseEther("12000000"), parseEther("13644919411200")])
            await expect(promise).to.be.revertedWith("Text too long")
        });


        it("test gas", async function () {
            const text = "abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd单独abc啦啦啦\ndsd"

            const hashResult = "0xb708e2cc056bcf9ca4672cd870c69296a57e05b339e82762edfa85860efd64b0"

            const transaction = await this.governance.connect(this.signer1).propose(1, 323n, text, [("12000000"), parseEther("13644919411200")])
            const result = await transaction.wait()
            const gasUsed0 = result.cumulativeGasUsed.toBigInt()

            console.log("gasUsed0: ", gasUsed0)

            const transaction1 = await this.governance.connect(this.signer1).propose(1, 323n, hashResult, [("12000000"), parseEther("13644919411200")])
            const result1 = await transaction1.wait()
            const gasUsed1 = result1.cumulativeGasUsed.toBigInt()

            console.log("gasUsed1: ", gasUsed1)
        });

        it("should revert insufficient fig when send do not have fig", async function () {

            const promise = this.governance.connect(this.signer4).propose(1, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000"), parseEther("13644919411200")])
            await expect(promise).to.be.revertedWith("ERC20: transfer amount exceeds balance")
        });

        it("should revert insufficient fig when send do not have fig 2", async function () {
            await this.filGovernance.connect(this.signer2).transfer(this.signer4.address, this.ONE_ETHER * 9999n) 
            const promise = this.governance.connect(this.signer4).propose(1, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000"), parseEther("13644919411200")])
            await expect(promise).to.be.revertedWith("ERC20: transfer amount exceeds balance")
        });


        it("Noarmal", async function () {
            await this.filGovernance.connect(this.signer2).transfer(this.signer4.address, this.ONE_ETHER * 10001n) 
            await this.governance.connect(this.signer4).propose(1, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000"), parseEther("13644919411200")])
        });


        it("should revert insufficient fig when send do not have fig 3", async function () {
            await filLiquid.connect(this.signer3).deposit(parseEther("10000000"), {value: parseEther("10000000")})
            await fitStake.connect(this.signer3).stakeFilTrust(parseEther("10000000"), 100230000, 2880 * 360)
            this.mineBlocks(2880 * 360)
            await fitStake.connect(signer3).withdrawFIGAll()
            const totalSupply = await this.filGovernance.totalSupply()
            console.log("totalSupply: ", totalSupply.toBigInt())

            const depositThreshold = await this.governance.getDepositThreshold()
            console.log("depositThreshold: ", depositThreshold.toBigInt())
            
            await this.filGovernance.connect(this.signer2).transfer(this.signer4.address, this.ONE_ETHER * 10001n)
            const promise = this.governance.connect(this.signer4).propose(1, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000"), parseEther("13644919411200")])
            await expect(promise).to.be.revertedWith("ERC20: transfer amount exceeds balance")
        });


        // it("normal test2", async function () {
        //     await filLiquid.connect(this.signer3).deposit(parseEther("10000000"), {value: parseEther("10000000")})
        //     await fitStake.connect(this.signer3).stakeFilTrust(parseEther("10000000"), 100230000, 2880 * 360)
        //     this.mineBlocks(2880 * 360)
        //     await fitStake.connect(signer3).withdrawFIGAll()
        //     const totalSUpply = await this.filGovernance.totalSupply()
        //     console.log("totalSUpply: ", totalSUpply)
        //     await this.filGovernance.connect(this.signer2).transfer(this.signer4.address, this.ONE_ETHER * 10001n)
        //     await this.governance.connect(this.signer4).propose(1, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000"), parseEther("13644919411200")])
        // });

        it("should store proposal info correctly", async function () {
            await this.governance.connect(this.signer2).propose(1, 323n, "abc啦啦啦\ndsd单独", [parseEther("12000000"), parseEther("13644919411200")])
            const proposalInfo = await this.governance.getProposalInfo(0)

            const block = await ethers.provider.getBlock()
            console.log("block.number: ", block.number)

            console.log("proposalInfo: ", proposalInfo)
            expect(proposalInfo.category).to.be.equal(1)
            expect(proposalInfo.start).to.be.equal(block.number)
            expect(proposalInfo.deadline).to.be.equal(block.number + 40320 + 1097)
            expect(proposalInfo.deposited).to.be.equal(parseEther("10000"))
            expect(proposalInfo.discussionIndex).to.be.equal(323)
            expect(proposalInfo.executed).to.be.equal(false)
            expect(proposalInfo.result).to.be.equal(3)
            expect(proposalInfo.category).to.be.equal(1)
            expect(proposalInfo.text).to.be.equal("abc啦啦啦\ndsd单独")
            expect(proposalInfo.proposer).to.be.equal(this.signer2.address)
        });
    });
}

module.exports = {
    tests,
}