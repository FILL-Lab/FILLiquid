const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("FILL", (m) => {
    const ONE_FIL = 10n ** 18n;
    // Get the foundation address
    const FOUNDATION_ADDRESS = m.getParameter("foundationAddress", "0xBf37F9f7C9Df3a71633E240f9C23581E0a958E2B");
    const INIT_DEPOSIT = m.getParameter("initDeposit", 10n * ONE_FIL);

    const validation = m.contract("Validation", []);
    const caculation = m.contract("Calculation", []);
    const filecoinAPI = m.contract("FilecoinAPI", []);

    const deployer1 = m.contract("Deployer1", [validation, caculation, filecoinAPI, FOUNDATION_ADDRESS]);
    const filTrustAddr = m.readEventArgument(deployer1, "ContractCreate", "contractAddr", { eventIndex: 0});
    const fitStakeAddr = m.readEventArgument(deployer1, "ContractCreate", "contractAddr", { eventIndex: 1});
    const governanceAddr = m.readEventArgument(deployer1, "ContractCreate", "contractAddr", { eventIndex: 2});
    const filGovernanceAddr = m.readEventArgument(deployer1, "ContractCreate", "contractAddr", { eventIndex: 3});

    const deployer2 = m.contract("Deployer2", [deployer1, validation, caculation, filecoinAPI, FOUNDATION_ADDRESS, filTrustAddr, fitStakeAddr, governanceAddr, filGovernanceAddr]);

    m.call(deployer1, "continueDeploy", [deployer2], {
        value: INIT_DEPOSIT
    });
    return { deployer1, deployer2 }
});