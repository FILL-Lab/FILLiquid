const { expect } = require("chai");
const { ethers, ignition } = require("hardhat");

const FILLModule = require("../ignition/modules/FILL");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

const ONE_FIL = 1000000000000000000n;
const initDepositValue = 1000n * ONE_FIL;

describe("FILL test", function() {
    async function deployFILLModuleFixture() {
        return ignition.deploy(FILLModule, {
            parameters: {
                FILLModule: {
                    "institutionSigners": ["0xBf37F9f7C9Df3a71633E240f9C23581E0a958E2B"],
                    "institutionApprovalThreshold": 1,
                    "teamSigners": ["0xBf37F9f7C9Df3a71633E240f9C23581E0a958E2B"],
                    "teamApprovalThreshold": 1,
                    "foundationSigners": ["0xBf37F9f7C9Df3a71633E240f9C23581E0a958E2B"],
                    "foundationApprovalThreshold": 1,
                    "reserveSigners": ["0xBf37F9f7C9Df3a71633E240f9C23581E0a958E2B"],
                    "reserveApprovalThreshold": 1,
                    "communitySigners": ["0xBf37F9f7C9Df3a71633E240f9C23581E0a958E2B"],
                    "communityApprovalThreshold": 1,
                    "feeReceiverSigners": ["0xBf37F9f7C9Df3a71633E240f9C23581E0a958E2B"],
                    "feeReceiverApprovalThreshold": 1,
                  
                    "initDepositValue": initDepositValue
                }
            },
        });
    }

    async function getContracts() {
        const { deployerFILL } = await loadFixture(deployFILLModuleFixture);
        const addrs = await deployerFILL.getFILLAddrs();
        console.log("addrs: ", addrs);
        const filTrust = await ethers.getContractAt("FILTrust", addrs[3]);
        const filLiquid = await ethers.getContractAt("FILLiquid", addrs[6]);
        return { filLiquid, filTrust }
    }

    it("Test getFitByDeposit after init", async function () {
        const [signer] = await ethers.getSigners();
        const depositAmount = ONE_FIL * 100n;
        const {filLiquid, filTrust} = await getContracts();

        let fitAmount = await filLiquid.getFitByDeposit(depositAmount);

        expect(fitAmount).to.equal(depositAmount);
        expect(depositAmount).to.equal(await filTrust.balanceOf(signer.address))
    });

    it("Test getFitByDeposit after redeem", async function () {
        const {fitTrust} = await getContracts();
        const depositAmount = ONE_FIL * 100n;
        const {filLiquid} = await getContracts();
        await filLiquid.getFilByRedeem(depositAmount - 1n);
        // console.log("redeem result: ", result);
        const result = await filLiquid.redeem(depositAmount - ONE_FIL + 1, depositAmount - ONE_FIL + 1);
        // console.log("redeem result: ", result);
        // let fitAmount = await filLiquid.getFitByDeposit(depositAmount);

        // expect(fitAmount).to.equal(depositAmount);
    });
});
