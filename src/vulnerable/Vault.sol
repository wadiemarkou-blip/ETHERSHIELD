// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - contrat volontairement vulnerable (Reentrancy).
contract Vault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        // VULNERABILITE : appel externe AVANT la mise a jour de l'etat
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "send failed");

        balances[msg.sender] = 0;
    }
}
