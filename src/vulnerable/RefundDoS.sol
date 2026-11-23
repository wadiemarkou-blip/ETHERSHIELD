// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - DoS par echec d'un appel externe (pattern "refund push").
contract RefundDoS {
    address public currentLeader;
    uint256 public currentBid;

    // VULNERABILITE : si le remboursement au leader precedent echoue,
    // toute la transaction revert et personne ne peut plus miser.
    function bid() external payable {
        require(msg.value > currentBid, "bid too low");

        if (currentLeader != address(0)) {
            (bool ok, ) = currentLeader.call{value: currentBid}("");
            require(ok, "refund failed");
        }

        currentLeader = msg.sender;
        currentBid = msg.value;
    }
}
