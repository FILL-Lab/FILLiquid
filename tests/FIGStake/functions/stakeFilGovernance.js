const { ethers } = require('ethers')
const { expect } = require("chai")

const parseEther = ethers.parseEther


function tests() {

    // beforeEach(async function () {
        
    // })

    describe('stakeFilGovernance', function () {
        it("should deposit correctly amount of FIG", async function () {
            console.log("aaaaa");
            // const amount = parseEther("4345.43")
            // await this.figStake.stakeFilGovernance(amount, 1000, 0)
        });
    });
}

module.exports = {
    tests,
}