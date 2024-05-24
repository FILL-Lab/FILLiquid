
function tests (fitStake) {
    describe('total supply', function () {
      it('returns the total amount of tokens', async function () {
        let status = await this.fitStake.getStatus()
        console.log("status: ", status)
        // expect(await this.token.totalSupply()).to.be.bignumber.equal(initialSupply);
      });
    });
  }

module.exports = {
    tests,
}