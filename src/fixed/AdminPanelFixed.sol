// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Version corrigee : Ownable + msg.sender.
contract AdminPanelFixed is Ownable {
    uint256 public feeBps;

    constructor() payable Ownable(msg.sender) {}

    receive() external payable {}

    function setFee(uint256 newFee) external onlyOwner {
        feeBps = newFee;
    }

    function sweep(address payable to) external onlyOwner {
        (bool ok, ) = to.call{value: address(this).balance}("");
        require(ok, "send failed");
    }
}
