// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;                 // version minimale du compilateur

/// @notice LABORATOIRE UNIQUEMENT - contrat volontairement vulnerable (Reentrancy).
contract Vault {

    // Le "cahier de comptes" : à chaque adresse correspond son solde en wei
    // public = Solidity crée automatiquement une fonction balances(adresse) pour le lire
    mapping(address => uint256) public balances;

    // DEPOT
    // payable = cette fonction peut recevoir des ETH
    function deposit() external payable {
        // msg.sender = celui qui appelle    msg.value = les ETH envoyés
        balances[msg.sender] += msg.value;   // on ajoute le montant à son solde
    }

    // RETRAIT
    function withdraw() external {

        // ETAPE 1 : je lis le solde de l'appelant dans le cahier
        uint256 amount = balances[msg.sender];

        // ETAPE 2 : je vérifie qu'il a de l'argent, sinon j'annule tout
        require(amount > 0, "no balance");

        // ETAPE 3 : J'ENVOIE L'ARGENT  <-- LA FAILLE EST ICI
        // call{value: amount}("") envoie des ETH à l'adresse
        // ok = true si l'envoi a réussi
        // VULNERABILITE : appel externe AVANT la mise a jour de l'etat
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "send failed");          // si l'envoi échoue, on annule

        // ETAPE 4 : je remets le solde à zéro  <-- TROP TARD
        balances[msg.sender] = 0;
    }
}