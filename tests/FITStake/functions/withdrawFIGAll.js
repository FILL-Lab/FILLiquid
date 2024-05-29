const { Contract, utils, ZERO_ADDRESS } = require('ethers')
const { expect } = require("chai")

const parseEther = utils.parseEther


const ONE_ETHER = BigInt(1e18)

function tests() {

    const STAKE_PERIOD = 2880 * 360
    const STAKE_AMOUNT = parseEther("10967").toBigInt();

    beforeEach(async function () {
        this.stakeSigner = this.singer2
        this.nonStakeSigner = this.singer3

        const transaction = await this.fitStake.connect(this.stakeSigner).stakeFilTrust(STAKE_AMOUNT, 100230000, STAKE_PERIOD)
        await transaction.wait()
        const receipt = await ethers.provider.getTransactionReceipt(transaction.hash);
        const log = receipt.logs[receipt.logs.length - 1];
        const decodedEvent = this.fitStake.interface.decodeEventLog("Staked", log.data, log.topics)
        const stakeId = decodedEvent.id.toBigInt()

        this.stakeId = stakeId
    })

    describe('withdrawFIGAll', function () {

        it("should get correctly amount of FIG", async function () {
            this.mineBlocks(STAKE_PERIOD/10)
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).withdrawFIGAll()
            // console.log("this.figGovernance: ", this.figGovernance)
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(41576562745869817993827n)
        });

        it("should get correctly amount of FIG 2", async function () {
            this.mineBlocks(STAKE_PERIOD/2)
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).withdrawFIGAll()
            // console.log("this.figGovernance: ", this.figGovernance)
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(207881209710763394622138n)
        });

        it("should get correctly amount of FIG when withdraw two times", async function () {
            this.mineBlocks(STAKE_PERIOD/2)
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).withdrawFIGAll()
            this.mineBlocks(STAKE_PERIOD/2)
            await this.fitStake.connect(signer).withdrawFIGAll()
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(415761617412233941570777n)
        });

        it("should get correctly amount of FIG when withdraw three times", async function () {
            this.mineBlocks(STAKE_PERIOD/2)
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).withdrawFIGAll()
            this.mineBlocks(STAKE_PERIOD/2)
            await this.fitStake.connect(signer).withdrawFIGAll()
            this.mineBlocks(STAKE_PERIOD/2)
            await this.fitStake.connect(signer).withdrawFIGAll()
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(415761617412233941570777n)
        });

        it("should get correctly amount of FIG when stake two times", async function () {
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).stakeFilTrust(STAKE_AMOUNT, 100230000, STAKE_PERIOD)
            this.mineBlocks(STAKE_PERIOD)
            await this.fitStake.connect(signer).withdrawFIGAll()
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(831283154654311295650377n)
        });
    });
}

module.exports = {
    tests,
}