// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {SigVault} from "../src/vulnerable/SigVault.sol";
import {SigVaultFixed} from "../src/fixed/SigVaultFixed.sol";

contract SigVaultTest is Test {
    SigVault vault;
    uint256 signerPk = 0xA11CE;
    address signer;
    address payable bob = payable(makeAddr("bob"));

    function setUp() public {
        signer = vm.addr(signerPk);
        vault = new SigVault{value: 10 ether}(signer);
    }

    function test_Exploit_SignatureReplay() public {
        // Le signataire autorise UN retrait de 1 ether pour Bob
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(bob, uint256(1 ether)))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        bytes memory sig = abi.encodePacked(r, s, v);

        // Bob rejoue la meme signature 5 fois
        for (uint256 i = 0; i < 5; i++) {
            vault.withdraw(bob, 1 ether, sig);
        }
        assertEq(bob.balance, 5 ether, "1 signature, 5 retraits");
    }
}

contract SigVaultFixedTest is Test {
    SigVaultFixed vault;
    uint256 signerPk = 0xA11CE;
    address signer;
    address payable bob = payable(makeAddr("bob"));

    function setUp() public {
        signer = vm.addr(signerPk);
        vault = new SigVaultFixed{value: 10 ether}(signer);
    }

    function _sign(uint256 amount, uint256 nonce, uint256 deadline) internal view returns (bytes memory) {
        bytes32 digest = vault.hashWithdraw(bob, amount, nonce, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        return abi.encodePacked(r, s, v);
    }

    function test_Fixed_FirstWithdrawWorks() public {
        uint256 deadline = block.timestamp + 1 hours;
        vault.withdraw(bob, 1 ether, 1, deadline, _sign(1 ether, 1, deadline));
        assertEq(bob.balance, 1 ether);
    }

    function test_Fixed_ReplayBlocked() public {
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(1 ether, 1, deadline);
        vault.withdraw(bob, 1 ether, 1, deadline, sig);

        vm.expectRevert(bytes("nonce used"));
        vault.withdraw(bob, 1 ether, 1, deadline, sig);
    }

    function test_Fixed_ExpiredSignatureRejected() public {
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(1 ether, 2, deadline);
        vm.warp(deadline + 1);
        vm.expectRevert(bytes("expired"));
        vault.withdraw(bob, 1 ether, 2, deadline, sig);
    }

    function test_Fixed_TamperedAmountRejected() public {
        uint256 deadline = block.timestamp + 1 hours;
        bytes memory sig = _sign(1 ether, 3, deadline);
        vm.expectRevert(bytes("bad sig"));
        vault.withdraw(bob, 9 ether, 3, deadline, sig);
    }
}
