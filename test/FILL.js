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

    async function getfilLiquid() {
        const { deployerFILL } = await loadFixture(deployFILLModuleFixture);
        console.log("FILLiquid address", await deployerFILL._filLiquid())
        const filLiquid = await ethers.getContractAt("FILLiquid", await deployerFILL._filLiquid());
        return { filLiquid }
    }

    it("Test getFitByDeposit after init", async function () {
        const depositAmount = ONE_FIL * 100n;
        const {filLiquid} = await getfilLiquid();
        let fitAmount = await filLiquid.getFitByDeposit(depositAmount);
        expect(fitAmount).to.equal(depositAmount);
    });


});
