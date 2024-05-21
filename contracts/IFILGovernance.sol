// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IFILGovernance is IERC20 {
    function withdraw(address account, uint256 amount) external;
    
    function mint(address account, uint256 amount) external;

    function burn(uint256 amount) external;

    function maxSupply() external view returns (uint);

    function maxLiquid() external view returns (uint);

    function addManager(address account) external;

    function removeManager(address account) external;

    function verifyManager(address account) external view returns (bool);

    function owner() external view returns (address);

    function setOwner(address new_owner) external returns (address);

    function burner() external view returns (address);

    function setBurner(address new_burner) external returns (address);
}
