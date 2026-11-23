// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice LABORATOIRE UNIQUEMENT - enchere naive vulnerable au front-running/MEV.
contract Auction {
    address public highestBidder;
    uint256 public highestBid;
    uint256 public immutable endTime;

    constructor(uint256 durationSeconds) {
        endTime = block.timestamp + durationSeconds;
    }

    // VULNERABILITE : l'offre est visible en clair dans le mempool.
    // Un attaquant peut observer une enchere en attente et la devancer
    // (front-running) avec une offre legerement superieure et un gas
    // price plus eleve, ou "sniper" juste avant endTime.
    function bid() external payable {
        require(block.timestamp < endTime, "auction ended");
        require(msg.value > highestBid, "bid too low");

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdraw(address payable to) external {
        require(block.timestamp >= endTime, "auction active");
        require(msg.sender == highestBidder, "not winner");
        (bool ok, ) = to.call{value: highestBid}("");
        require(ok, "send failed");
    }
}
