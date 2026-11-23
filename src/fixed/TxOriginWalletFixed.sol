// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
contract TxOriginWalletFixed {address public owner;constructor() payable{owner=msg.sender;}receive() external payable{}function transfer(address payable to,uint256 amount) external {require(msg.sender==owner,"not owner");require(to!=address(0),"zero recipient");(bool ok,)=to.call{value:amount}("");require(ok,"send failed");}}
