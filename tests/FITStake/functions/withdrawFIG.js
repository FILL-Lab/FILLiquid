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

    describe('withrawFIG', function () {
        it("should revert Invalid stakeId", async function () {
            this.mineBlocks(STAKE_PERIOD)
            let promise = this.fitStake.connect(this.singer1).withrawFIG(this.stakeId)
            await expect(promise).to.be.revertedWith("Invalid stakeId")
        })

        it("should get correctly amount of FIG", async function () {
            this.mineBlocks(STAKE_PERIOD/10)
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).withdrawFIG(this.stakeId)
            // console.log("this.figGovernance: ", this.figGovernance)
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(41576562745869817993827n)
        });

        it("should get correctly amount of FIG 2", async function () {
            this.mineBlocks(STAKE_PERIOD/2)
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).withdrawFIG(this.stakeId)
            // console.log("this.figGovernance: ", this.figGovernance)
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(207881209710763394622138n)
        });

        it("should get correctly amount of FIG when withdraw two times", async function () {
            this.mineBlocks(STAKE_PERIOD/2)
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).withdrawFIG(this.stakeId)
            this.mineBlocks(STAKE_PERIOD/2)
            await this.fitStake.connect(signer).withdrawFIG(this.stakeId)
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(415761617412233941570777n)
        });


        it("should get correctly amount of FIG when withdraw three times", async function () {
            this.mineBlocks(STAKE_PERIOD/2)
            const signer = this.stakeSigner
            await this.fitStake.connect(signer).withdrawFIG(this.stakeId)
            this.mineBlocks(STAKE_PERIOD/2)
            await this.fitStake.connect(signer).withdrawFIG(this.stakeId)
            this.mineBlocks(STAKE_PERIOD/2)
            await this.fitStake.connect(signer).withdrawFIG(this.stakeId)
            const balanceFIG = await this.filGovernance.balanceOf(signer.address)
            expect(balanceFIG.toBigInt()).to.be.equal(415761617412233941570777n)
        });
    });
}

module.exports = {
    tests,
}