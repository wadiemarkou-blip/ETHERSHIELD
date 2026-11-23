// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - authentification via tx.origin (phishing).
contract TxOriginWallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    receive() external payable {}

    // VULNERABILITE : tx.origin au lieu de msg.sender
    function transfer(address payable to, uint256 amount) external {
        require(tx.origin == owner, "not owner");
        (bool ok, ) = to.call{value: amount}("");
        require(ok, "send failed");
    }
}
