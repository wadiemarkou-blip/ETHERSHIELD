// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - Front-running : la reponse est visible dans le mempool.
contract RewardPuzzle {

    // On ne stocke que le HASH de la réponse, pas la réponse elle-même
    // immutable = fixé à la création, jamais modifiable
    bytes32 public immutable answerHash;

    bool public solved;   // true quand l'énigme est résolue

    // payable : la cagnotte est déposée dès la création
    constructor(bytes32 _answerHash) payable {
        answerHash = _answerHash;
    }

    // VULNERABILITE : la reponse est en clair dans la transaction.
    // Un attaquant la copie et envoie la sienne avant (gas plus eleve).
    function solve(string calldata answer) external {
        require(!solved, "already solved");                          // pas déjà résolue
        require(keccak256(bytes(answer)) == answerHash, "wrong answer"); 

        solved = true;                                               // on marque résolue
//Où est la faille : pas dans le stockage, mais dans la transaction elle-même. 
//Quand le gagnant honnête appelle solve("ethershield"), la réponse "ethershield" est écrite en clair dans les données de la transaction,
// visibles dans le mempool avant qu’elle soit exécutée.
        // le gagnant reçoit TOUTE la cagnotte
        (bool ok, ) = msg.sender.call{value: address(this).balance}("");
        require(ok, "send failed");
    }
}