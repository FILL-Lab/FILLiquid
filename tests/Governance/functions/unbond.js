const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { expect } = require("chai")

const parseEther = utils.parseEther


function tests() {

    beforeEach(async function () {
        this.bondSigner = this.signer2
        this.noBondSigner = this.signer3
        // await this.fitStake.connect(filLiquidMockSigner).handleInterest(this.bondSigner.address, parseEther("12323210000"), parseEther("10000").toBigInt())

        const boundAmount = parseEther("2321.4")
        await this.governance.connect(this.bondSigner).bond(boundAmount)
        this.bondedAmount = boundAmount
        
    })

    describe('unbond', function () {

        it("should reduce correctly bound amount", async function () {
            const unboundAmount = parseEther("34.235")
            const boundAmountBefore = await this.governance.bondedAmount(this.bondSigner.address)
            await this.governance.connect(this.bondSigner).unbond(unboundAmount)
            const boundAmountAfter = await this.governance.bondedAmount(this.bondSigner.address)

            expect(await this.governance.bondedAmount(this.noBondSigner.address)).to.be.equal(parseEther("0"))
            expect(boundAmountBefore.toBigInt() - boundAmountAfter.toBigInt()).to.be.equal(unboundAmount.toBigInt())
        });

        it("should get correctly amount of FIG", async function () {
            const balanceFigBefore = await this.filGovernance.balanceOf(this.bondSigner.address)
            const unboundAmount = parseEther("34.235")
            await this.governance.connect(this.bondSigner).unbond(unboundAmount)
            const balanceFigAfter = await this.filGovernance.balanceOf(this.bondSigner.address)
            await this.governance.bondedAmount(this.bondSigner.address)
            expect(await this.governance.bondedAmount(this.noBondSigner.address)).to.be.equal(parseEther("0"))
            expect(balanceFigAfter.toBigInt() - balanceFigBefore.toBigInt()).to.be.equal(unboundAmount.toBigInt())
        });

        // it("should revert when unbound exceeds bound", async function () {
        //     const unboundAmount = this.bondedAmount.toBigInt() + 1n
        //     await expect(this.governance.connect(this.bondSigner).unbond(unboundAmount)).to.be.revertedWith("unbound exceeds bound")
        // });

        it("should get correctly amount of FIG when unbound exceeds bound", async function () {
            const balanceFigBefore = await this.filGovernance.balanceOf(this.bondSigner.address)
            const unboundAmount = this.bondedAmount.toBigInt() + this.ONE_ETHER * 10023n
            await this.governance.connect(this.bondSigner).unbond(unboundAmount)
            const balanceFigAfter = await this.filGovernance.balanceOf(this.bondSigner.address)
            await this.governance.bondedAmount(this.bondSigner.address)
            expect(await this.governance.bondedAmount(this.noBondSigner.address)).to.be.equal(parseEther("0"))
            expect(balanceFigAfter.toBigInt() - balanceFigBefore.toBigInt()).to.be.equal(this.bondedAmount.toBigInt())
        });
    });
}

module.exports = {
    tests,
}