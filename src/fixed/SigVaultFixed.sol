// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/// @notice Version corrigee : EIP-712 (separation de domaine) + nonce + expiration.
contract SigVaultFixed is EIP712 {
    bytes32 private constant WITHDRAW_TYPEHASH =
        keccak256("Withdraw(address to,uint256 amount,uint256 nonce,uint256 deadline)");

    address public immutable signer;
    mapping(uint256 => bool) public usedNonces;

    constructor(address _signer) payable EIP712("SigVaultFixed", "1") {
        signer = _signer;
    }

    receive() external payable {}

    /// @dev Helper pour que les tests / le signataire calculent le digest EIP-712.
    function hashWithdraw(address to, uint256 amount, uint256 nonce, uint256 deadline)
        public
        view
        returns (bytes32)
    {
        return _hashTypedDataV4(
            keccak256(abi.encode(WITHDRAW_TYPEHASH, to, amount, nonce, deadline))
        );
    }

    function withdraw(
        address payable to,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes calldata sig
    ) external {
        require(block.timestamp <= deadline, "expired");
        require(!usedNonces[nonce], "nonce used");
        require(ECDSA.recover(hashWithdraw(to, amount, nonce, deadline), sig) == signer, "bad sig");

        usedNonces[nonce] = true;

        (bool ok, ) = to.call{value: amount}("");
        require(ok, "send failed");
    }
}
