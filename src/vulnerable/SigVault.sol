// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/// @notice LABORATOIRE UNIQUEMENT - Signature rejouable (pas de nonce, expiration, domaine).
contract SigVault {
    address public immutable signer;

    constructor(address _signer) payable {
        signer = _signer;
    }

    receive() external payable {}

    function withdraw(address payable to, uint256 amount, bytes calldata sig) external {
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(to, amount))
        );
        require(ECDSA.recover(digest, sig) == signer, "bad sig");

        // VULNERABILITE : la meme signature peut etre rejouee indefiniment
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "send failed");
    }
}
