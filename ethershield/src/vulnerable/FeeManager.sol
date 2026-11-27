// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - Access control manquant.
contract FeeManager {

    address public owner;      // l'adresse du propriétaire (public = lisible par tous)
    uint256 public feeBps;     // les frais en "points de base" (bps)
                               // 100 bps = 1 %    10 000 bps = 100 %

    constructor() {
        owner = msg.sender;    // celui qui déploie devient le propriétaire
        feeBps = 100;          // frais de départ : 1 %
    }

    // VULNERABILITE : n'importe qui peut modifier un parametre critique
    function setFee(uint256 newFee) external {
        feeBps = newFee;       // aucune vérification de qui appelle !
    }
}