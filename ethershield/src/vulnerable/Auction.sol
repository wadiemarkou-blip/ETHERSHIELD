// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - DoS par echec d'appel externe (bonus).
contract Auction {

    address public leader;          // celui qui a la meilleure offre actuellement
    uint256 public highestBid;      // le montant de la meilleure offre

    function bid() external payable {

        // 1. Mon offre doit être strictement supérieure à l'offre actuelle
        require(msg.value > highestBid, "too low");

        // VULNERABILITE : si l'ancien leader refuse les ETH, plus personne ne peut enchérir
        // 2. Je REMBOURSE l'ancien leader avant de prendre sa place
        if (leader != address(0)) {
            (bool ok, ) = leader.call{value: highestBid}("");
            require(ok, "refund failed");      // si le remboursement échoue : TOUT est annulé
        }

        // 3. Je deviens le nouveau leader
        leader = msg.sender;
        highestBid = msg.value;
    }
}