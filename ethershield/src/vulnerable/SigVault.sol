// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Outils d'OpenZeppelin pour vérifier une signature et fabriquer le message à signer
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/// @notice LABORATOIRE UNIQUEMENT - Signature rejouable (pas de nonce, expiration, domaine).
contract SigVault {

    address public immutable signer;       // le signataire de confiance (fixé à la création)

    constructor(address _signer) payable {
        signer = _signer;                  // on enregistre qui a le droit d'autoriser
    }

    receive() external payable {}          // permet d'alimenter le vault en ETH

    function withdraw(address payable to, uint256 amount, bytes calldata sig) external {

        // 1. On reconstruit le message qui a été signé : (à qui, combien)
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(to, amount))
        );

        // 2. On vérifie que la signature vient bien du signataire
        require(SignatureChecker.isValidSignatureNow(signer, digest, sig), "bad sig");

        // VULNERABILITE : la meme signature peut etre rejouee indefiniment
        (bool ok, ) = to.call{value: amount}("");    // 3. on paie
        require(ok, "send failed");
        // et on n'écrit RIEN qui dise "cette signature a déjà servi"
    } //Où est la faille : le contrat vérifie la signature,
    // mais ne garde aucune trace de son utilisation. 
    //À chaque appel, il refait la même vérification, qui réussit encore, et il paie encore.
}