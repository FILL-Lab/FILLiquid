const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { expect } = require("chai")

const parseEther = utils.parseEther


function tests() {

    beforeEach(async function () {
        this.figSigner = this.signer2
        this.noFigSigner = this.signer4
        // await this.fitStake.connect(filLiquidMockSigner).handleInterest(this.figSigner.address, parseEther("12323210000"), parseEther("100000000000000").toBigInt())

    })

    describe('bond', function () {

        it("should deposit correctly amount of FIG", async function () {
            const boundAmount = parseEther("2321.4")
            const balanceFigBefore = await this.filGovernance.balanceOf(this.figSigner.address)
            await this.governance.connect(this.figSigner).bond(boundAmount)
            const balanceFigAfter = await this.filGovernance.balanceOf(this.figSigner.address)
            expect(await this.governance.bondedAmount(this.figSigner.address)).to.be.equal(boundAmount)
            expect(await this.governance.bondedAmount(this.noFigSigner.address)).to.be.equal(parseEther("0"))
            expect(balanceFigBefore.toBigInt() - balanceFigAfter.toBigInt()).to.be.equal(boundAmount.toBigInt())
        });

        it("should deposit correctly amount of FIG when bond a large amount", async function () {
            const boundAmount = parseEther("412345678")
            const balanceFigBefore = await this.filGovernance.balanceOf(this.figSigner.address)
            await this.governance.connect(this.figSigner).bond(boundAmount)
            const balanceFigAfter = await this.filGovernance.balanceOf(this.figSigner.address)
            expect(await this.governance.bondedAmount(this.figSigner.address)).to.be.equal(boundAmount)
            expect(await this.governance.bondedAmount(this.noFigSigner.address)).to.be.equal(parseEther("0"))
            expect(balanceFigBefore.toBigInt() - balanceFigAfter.toBigInt()).to.be.equal(boundAmount.toBigInt())
        });

        it("should revert insufficient FIG", async function () {
            const balanceFig = await this.filGovernance.balanceOf(this.figSigner.address)
            const bondAmount = balanceFig.toBigInt() + 1
            await this.governance.connect(this.figSigner).bond(bondAmount)
        });

    });
}

module.exports = {
    tests,
}