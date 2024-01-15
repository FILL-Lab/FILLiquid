// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Context.sol";

import "filecoin-solidity-api/contracts/v0.8/AccountAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/MinerAPI.sol";
import "filecoin-solidity-api/contracts/v0.8/PrecompilesAPI.sol";

contract Validation is Context {
    mapping(bytes => uint256) private _nonces;

    function validateOwner(
        uint64 minerID,
        bytes calldata signature,
        address sender
    ) external {
        if (signature.length == 97) signature = signature[1:];
        require (signature.length == 96, "Invalid signature length");

        CommonTypes.FilAddress memory ownerAddr = _getOwner(minerID);
        bytes memory digest = _getDigest(
            ownerAddr.data,
            minerID,
            sender
        );
        int256 exitCode = AccountAPI.authenticateMessage(
            CommonTypes.FilActorId.wrap(PrecompilesAPI.resolveAddress(ownerAddr)),
            AccountTypes.AuthenticateMessageParams({
                signature: signature,
                message: digest
            })
        );
        require(exitCode == 0, "Error authenticating message");
        _nonces[ownerAddr.data] += 1;
    }

    function getSigningMsg(uint64 minerID) external view returns (bytes memory m) {
        return _getDigest(_getOwner(minerID).data, minerID, _msgSender());
    }

    function getNonce(bytes calldata addr) external view returns (uint256) {
        return _nonces[addr];
    }

    function _getDigest(
        bytes memory ownerAddr,
        uint64 minerID,
        address sender
    ) private view returns (bytes memory) {
        bytes32 digest = keccak256(abi.encode(
            keccak256("validateOwner"),
            ownerAddr,
            minerID,
            sender,
            _nonces[ownerAddr],
            _getChainId()
        ));
        return bytes.concat(digest);
    }

    function _getOwner(uint64 minerId) private view returns (CommonTypes.FilAddress memory) {
        (int256 exitCode, MinerTypes.GetOwnerReturn memory result) = MinerAPI.getOwner(_wrapId(minerId));
        require(exitCode == 0, "Error getOwner");
        return result.owner;
    }

    function _getChainId() private view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }

    function _wrapId(uint64 actorId) private pure returns(CommonTypes.FilActorId) {
        return CommonTypes.FilActorId.wrap(actorId);
    }
}
