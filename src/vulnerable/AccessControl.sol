// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - Access Control manquant sur des parametres critiques.
contract AccessControl {
    address public admin;
    uint256 public feeBps;
    address public treasury;

    constructor(address _treasury) {
        admin = msg.sender;
        treasury = _treasury;
    }

    // VULNERABILITE : aucune verification que msg.sender == admin
    function setFee(uint256 newFeeBps) external {
        feeBps = newFeeBps;
    }

    // VULNERABILITE : n'importe qui peut rediriger la tresorerie
    function setTreasury(address newTreasury) external {
        treasury = newTreasury;
    }

    function withdraw() external {
        (bool ok, ) = treasury.call{value: address(this).balance}("");
        require(ok, "send failed");
    }

    receive() external payable {}
}
