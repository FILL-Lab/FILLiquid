const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("FILL", (m) => {
    const ONE_FIL = 10n ** 18n;
    // Get the foundation address
    const institutionSigners = m.getParameter("institutionSigners");
    const institutionApprovalThreshold = m.getParameter("institutionApprovalThreshold");
    const teamSigners = m.getParameter("teamSigners");
    const teamApprovalThreshold = m.getParameter("teamApprovalThreshold");
    const foundationSigners = m.getParameter("foundationSigners");
    const foundationApprovalThreshold = m.getParameter("foundationApprovalThreshold");
    const reserveSigners = m.getParameter("reserveSigners");
    const reserveApprovalThreshold = m.getParameter("reserveApprovalThreshold");
    const communitySigners = m.getParameter("communitySigners");
    const communityApprovalThreshold = m.getParameter("communityApprovalThreshold");
    const feeReceiverSigners = m.getParameter("feeReceiverSigners");
    const feeReceiverApprovalThreshold = m.getParameter("feeReceiverApprovalThreshold");
    const initDepositValue = m.getParameter("initDepositValue");

    // Utils
    const deployerUtils = m.contract("DeployerUtils", []);
    // MultiSigner
    const deployerFeeMultiSigner = m.contract("DeployerFeeMultiSigner", [feeReceiverSigners, feeReceiverApprovalThreshold]);
    const deployerFIGMultiSigner = m.contract("DeployerFIGMultiSigner", [
        institutionSigners, institutionApprovalThreshold,
        teamSigners, teamApprovalThreshold,
        foundationSigners, foundationApprovalThreshold,
        reserveSigners, reserveApprovalThreshold,
        communitySigners, communityApprovalThreshold,
    ]);

    // FIG 以及分配FIG Token
    const deployerFIG = m.contract("DeployerFIG", [deployerFIGMultiSigner]);

    // FIT、FITStake、Governance
    const deployerMix = m.contract("DeployerMix", []); 

    const deployerFILL = m.contract("DeployerFILL", [deployerUtils, deployerMix, deployerFIG, deployerFIGMultiSigner, deployerFeeMultiSigner]);

    const settingFIG = m.call(deployerFIG, "setting", [deployerFILL]);
    m.call(deployerMix, "setting", [deployerFILL], {
        value: initDepositValue,
        after: [settingFIG]
    });

    return { deployerFILL }
});