// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AdminPanel} from "../src/vulnerable/AdminPanel.sol";
import {AdminPanelFixed} from "../src/fixed/AdminPanelFixed.sol";
import {PhishingContract} from "./Attackers.sol";

contract AdminPanelTest is Test {
    AdminPanel panel;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        panel = new AdminPanel{value: 5 ether}();
    }

    function test_Exploit_AnyoneCanSetFee() public {
        vm.prank(attacker);
        panel.setFee(10_000);
        assertEq(panel.feeBps(), 10_000);
    }

    function test_Exploit_TxOriginPhishing() public {
        PhishingContract trap = new PhishingContract(address(panel), payable(attacker));

        // Le proprietaire appelle le contrat piege : msg.sender = trap, tx.origin = owner
        vm.prank(owner, owner);
        trap.claimPrize();

        assertEq(attacker.balance, 5 ether, "attacker stole the funds");
        assertEq(address(panel).balance, 0);
    }
}

contract AdminPanelFixedTest is Test {
    AdminPanelFixed panel;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        panel = new AdminPanelFixed{value: 5 ether}();
    }

    function test_Fixed_SetFeeRestricted() public {
        vm.prank(attacker);
        vm.expectRevert();
        panel.setFee(10_000);
    }

    function test_Fixed_PhishingBlocked() public {
        PhishingContract trap = new PhishingContract(address(panel), payable(attacker));
        vm.prank(owner, owner);
        vm.expectRevert();
        trap.claimPrize();
        assertEq(address(panel).balance, 5 ether);
    }

    function test_Fixed_OwnerCanStillSweep() public {
        vm.prank(owner);
        panel.sweep(payable(owner));
        assertEq(owner.balance, 10 ether);
    }
}
