
// function tests() {

//     const STAKE_PERIOD = 2880 * 360
//     const STAKE_AMOUNT = parseEther("10967").toBigInt();

//     beforeEach(async function () {
//         this.stakeSigner = this.singer2
//         this.nonStakeSigner = this.singer3

//         const transaction = await this.fitStake.connect(this.stakeSigner).stakeFilTrust(STAKE_AMOUNT, 100230000, STAKE_PERIOD)
//         await transaction.wait()
//         const receipt = await ethers.provider.getTransactionReceipt(transaction.hash);
//         const log = receipt.logs[receipt.logs.length - 1];
//         const decodedEvent = this.fitStake.interface.decodeEventLog("Staked", log.data, log.topics)
//         const stakeId = decodedEvent.id.toBigInt()

//         this.stakeId = stakeId
//     })

//     describe('withrawFIG', function () {
//         it("should revert Invalid stakeId", async function () {
//             this.mineBlocks(STAKE_PERIOD)
//             let promise = this.fitStake.connect(this.singer1).unStakeFilTrust(this.stakeId)
//             await expect(promise).to.be.revertedWith("Invalid stakeId")
//         })

//         it("should get correctly amount of FIG", async function () {
//             this.mineBlocks(STAKE_PERIOD/10)
//             await this.fitStake.connect(this.singer1).withrawFIG(this.stakeId)
//             const balanceFIG = await this.figGovernance.balanceOf(this.singer1.address)
//             expect(balanceFIG).to.be.equal(parseEther("10967"))
            



//             // let amount = this.constants.ONE_ETHER * 100
//             // let signer = this.singer2
//             // this.fitStake.connect(signer).stakeFilTrust(amount, 10000, 23043)
//             // let status = await fitStake.getStatus()
//         });
//     });
// }

// module.exports = {
//     tests,
// }