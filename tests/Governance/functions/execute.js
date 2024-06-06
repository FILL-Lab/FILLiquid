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

            const factorsBefore = await this.fitStake.getAllFactors()
            expect(factorsBefore[0]).to.be.equal(parseEther("12000000"))
            expect(factorsBefore[1]).to.be.equal(parseEther("13644919411200"))
            await this.governance.connect(this.proposer).execute(this.proposalId)
            const factorsAfter = await this.fitStake.getAllFactors()
            expect(factorsAfter[0]).to.be.equal(parseEther("13123456"))
            expect(factorsAfter[1]).to.be.equal(parseEther("14644919411234"))
        });


        it("should set correctly factors of FILLiquid after execution", async function () {
            await this.governance.propose(0, 32323n, "abc啦啦啦\ndsd单独", [500001n, 10002n, 100003n, 600004n, 500005n, 6n, 750007n, 850008n, 19n, 43210n, 900011n, 70012n, 13n, parseEther("14"), parseEther("15")])

            const proposalId = 2

            await this.governance.connect(this.bondSigner).vote(proposalId, 0, this.bondedAmount.toBigInt()/10n*5n)
            await this.governance.connect(this.bondSigner2).vote(proposalId, 0, this.bondedAmount2.toBigInt()/10n*4n)
            await this.mineBlocks(2880*16)
            await this.governance.connect(this.proposer).execute(proposalId)
            // const allFactors = await this.fitStake.getAllFactors()
            // expect(allFactors[0]).to.be.equal(parseEther("13123456"))
            // expect(allFactors[1]).to.be.equal(parseEther("14644919411234"))
            const borrowPayBackFactors = await this.filLiquid.getBorrowPayBackFactors()
            // return (_u_1, _r_0, _r_1, _r_m, _n);
            // _u_1 = values[0];
            // _r_0 = values[1];
            // _r_1 = values[2];
            // _r_m = values[3];
            // _collateralRate = values[4];
            // _maxFamilySize = values[5];
            // _alertThreshold = values[6];
            // _liquidateThreshold = values[7];
            // _maxLiquidations = values[8];
            // _minLiquidateInterval = values[9];
            // _liquidateDiscountRate = values[10];
            // _liquidateFeeRate = values[11];
            // _maxExistingBorrows = values[12];
            // _minBorrowAmount = values[13];
            // _minDepositAmount = values[14];

            expect(borrowPayBackFactors[0]).to.be.equal(500001n)
            expect(borrowPayBackFactors[1]).to.be.equal(10002n)
            expect(borrowPayBackFactors[2]).to.be.equal(100003n)
            expect(borrowPayBackFactors[3]).to.be.equal(600004n)

            // function getComprehensiveFactors() external view returns (uint, uint, uint, uint, uint, uint, uint, uint, uint, int64) {
            //     return (
            //         _rateBase,
            //         _redeemFeeRate,
            //         _borrowFeeRate,
            //         _collateralRate,
            //         _minDepositAmount,
            //         _minBorrowAmount,
            //         _maxExistingBorrows,
            //         _maxFamilySize,
            //         _requiredQuota,
            //         _requiredExpiration
            //     );
            // }

            // [500001n, 10002n, 100003n, 600004n, 500005n, 6n, 750007n, 850008n, 19n, 43210n, 900011n, 70012n, 13n, parseEther("14"), parseEther("15")]

            const comprehensiveFactors = await this.filLiquid.getComprehensiveFactors()

            expect(comprehensiveFactors[3]).to.be.equal(500005n)
            expect(comprehensiveFactors[4]).to.be.equal(parseEther("15"))
            expect(comprehensiveFactors[5]).to.be.equal(parseEther("14"))
            expect(comprehensiveFactors[6]).to.be.equal(13n)
            expect(comprehensiveFactors[7]).to.be.equal(6n)

            // function getLiquidatingFactors() external view returns (uint, uint, uint, uint, uint, uint) {
            //     return (
            //         _maxLiquidations,
            //         _minLiquidateInterval,
            //         _alertThreshold,
            //         _liquidateThreshold,
            //         _liquidateDiscountRate,
            //         _liquidateFeeRate
            //     );
            // }

            // getLiquidatingFactors

            const liquidatingFactors = await this.filLiquid.getLiquidatingFactors()
            expect(liquidatingFactors[0]).to.be.equal(19n)
            expect(liquidatingFactors[1]).to.be.equal(43210n)
            expect(liquidatingFactors[2]).to.be.equal(750007n)
            expect(liquidatingFactors[3]).to.be.equal(850008n)
            expect(liquidatingFactors[4]).to.be.equal(900011n)
            expect(liquidatingFactors[5]).to.be.equal(70012n)



        });
    });
}

module.exports = {
    tests,
}