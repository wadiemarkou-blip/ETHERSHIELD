// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - Authentification par tx.origin.
contract TxOriginWallet {

    address public owner;     // le propriétaire du portefeuille

    // payable = on peut y mettre des ETH dès la création
    constructor(address _owner) payable {
        owner = _owner;        // on enregistre le propriétaire
    }

    // receive() permet de recevoir des ETH par un simple virement
    receive() external payable {}

    // Envoie des ETH vers l'adresse "to"
    function transferTo(address payable to, uint256 amount) external {

        // VULNERABILITE : on vérifie QUI A LANCÉ la transaction, pas qui APPELLE
        // tx.origin = l'EOA qui a lancé la transaction,
        // meme si elle passe par un contrat malveillant (phishing)
        require(tx.origin == owner, "not owner");

        (bool ok, ) = to.call{value: amount}("");   // envoi de l'argent
        require(ok, "send failed");
    }
}