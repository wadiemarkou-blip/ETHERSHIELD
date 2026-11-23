// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - Access control manquant + tx.origin.
contract AdminPanel {
    address public owner;
    uint256 public feeBps;

    constructor() payable {
        owner = msg.sender;
    }

    receive() external payable {}

    // VULNERABILITE 1 : aucun controle d'acces
    function setFee(uint256 newFee) external {
        feeBps = newFee;
    }

    // VULNERABILITE 2 : authentification via tx.origin (phishing possible)
    function sweep(address payable to) external {
        require(tx.origin == owner, "not owner");
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "send failed");
    }
}
