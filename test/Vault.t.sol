// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/vulnerable/Vault.sol";
import {VaultFixed} from "../src/fixed/VaultFixed.sol";
import {ReentrancyAttacker} from "./Attackers.sol";

contract VaultTest is Test {
    Vault vault;
    address alice = makeAddr("alice");

    function setUp() public {
        vault = new Vault();
        vm.deal(alice, 10 ether);
        vm.prank(alice);
        vault.deposit{value: 10 ether}();
        vm.deal(address(this), 1 ether);
    }

    function test_Exploit_ReentrancyDrainsVault() public {
        ReentrancyAttacker atk = new ReentrancyAttacker(address(vault));
        atk.attack{value: 1 ether}();

        assertEq(address(vault).balance, 0, "vault should be drained");
        assertEq(address(atk).balance, 11 ether, "attacker stole alice funds");
    }
}

contract VaultFixedTest is Test {
    VaultFixed vault;
    address alice = makeAddr("alice");

    function setUp() public {
        vault = new VaultFixed();
        vm.deal(alice, 10 ether);
        vm.prank(alice);
        vault.deposit{value: 10 ether}();
        vm.deal(address(this), 1 ether);
    }

    function test_Fixed_ReentrancyBlocked() public {
        ReentrancyAttacker atk = new ReentrancyAttacker(address(vault));
        vm.expectRevert();
        atk.attack{value: 1 ether}();
        assertEq(address(vault).balance, 10 ether, "funds intact");
    }

    function test_Fixed_NormalWithdrawWorks() public {
        vm.prank(alice);
        vault.withdraw();
        assertEq(alice.balance, 10 ether);
        assertEq(vault.balances(alice), 0);
    }

    /// Fuzz : deposer puis retirer rend exactement le montant.
    function testFuzz_DepositWithdrawRoundTrip(uint96 amount) public {
        amount = uint96(bound(amount, 1, 100 ether));
        address bob = makeAddr("bob");
        vm.deal(bob, amount);
        vm.startPrank(bob);
        vault.deposit{value: amount}();
        vault.withdraw();
        vm.stopPrank();
        assertEq(bob.balance, amount);
    }
}
