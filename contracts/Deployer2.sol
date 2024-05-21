// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Utils/Calculation.sol";
import "./Utils/Validation.sol";
import "./Utils/FilecoinAPI.sol";

import "./FILTrust.sol";
import "./FILLiquid.sol";
import "./Governance.sol";
import "./FILGovernance.sol";
import "./DataFetcher.sol";

contract Deployer2 {
    address _owner;

    Validation private _validation;
    Calculation private _calculation;
    FilecoinAPI private _filecoinAPI;
    FILTrust private _filTrust;
    FITStake private _fitStake;
    Governance private _governance;
    FILGovernance private _filGovernance;

    FILLiquid private _filLiquid;

    constructor(
        address deloyer1, 
        address validation, 
        address calculation, 
        address filecoinAPI, 
        address payable foundationAddr, 
        address filTrust, 
        address fitStake, 
        address governance,
        address filGovernance
    ) {
        _owner = deloyer1;

        _validation = Validation(validation);
        _calculation = Calculation(calculation);
        _filecoinAPI = FilecoinAPI(filecoinAPI);
        _filTrust = FILTrust(filTrust);
        _fitStake = FITStake(fitStake);
        _governance = Governance(governance);
        _filGovernance = FILGovernance(filGovernance);

        _filLiquid = new FILLiquid(
            filTrust,
            validation,
            calculation,
            filecoinAPI,
            fitStake,
            governance,
            foundationAddr
        );
    }

    function finalize() public payable {
        require(msg.sender == _owner, "Deployer2: only owner can finalize deploy");
        _owner = address(0);
        // 6. Create DataFetcher
        new DataFetcher(_filLiquid, _filTrust, _fitStake, _filGovernance, _governance, FilecoinAPI(_filecoinAPI));

        // 7. Setup parameters
        _fitStake.setContractAddrs(
            address(_filLiquid),
            address(_governance),
            address(_filTrust),
            address(_calculation),
            address(_filGovernance)
        );

        _governance.setContractAddrs(
            address(_filLiquid),
            address(_fitStake),
            address(_filGovernance)
        );
        _filTrust.addManager(address(_filLiquid));
        _filTrust.addManager(address(_fitStake));

        _filGovernance.addManager(address(_fitStake));
        _filGovernance.addManager(address(_governance));

        // 8. Inital deposit
        _filLiquid.deposit{value: msg.value}(msg.value);
        uint filTrustBalance = _filTrust.balanceOf(address(this));
        assert(filTrustBalance == msg.value);
        _filTrust.transfer(msg.sender, filTrustBalance);

        _filGovernance.transfer(msg.sender, _filGovernance.balanceOf(address(this)));
    }
}