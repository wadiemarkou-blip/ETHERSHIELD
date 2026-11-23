// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/vulnerable/Vault.sol";
import {VaultFixed} from "../src/fixed/VaultFixed.sol";
import {AdminPanel} from "../src/vulnerable/AdminPanel.sol";
import {AdminPanelFixed} from "../src/fixed/AdminPanelFixed.sol";
import {SigVault} from "../src/vulnerable/SigVault.sol";
import {SigVaultFixed} from "../src/fixed/SigVaultFixed.sol";
import {Auction} from "../src/vulnerable/Auction.sol";
import {AuctionFixed} from "../src/fixed/AuctionFixed.sol";

/// Deploiement sur Anvil UNIQUEMENT (cles et fonds fictifs).
contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        Vault v = new Vault();
        VaultFixed vf = new VaultFixed();
        AdminPanel ap = new AdminPanel{value: 1 ether}();
        AdminPanelFixed apf = new AdminPanelFixed{value: 1 ether}();
        SigVault sv = new SigVault{value: 1 ether}(msg.sender);
        SigVaultFixed svf = new SigVaultFixed{value: 1 ether}(msg.sender);
        Auction auction = new Auction();
        AuctionFixed auctionFixed = new AuctionFixed();

        vm.stopBroadcast();

        console.log("Vault          :", address(v));
        console.log("VaultFixed     :", address(vf));
        console.log("AdminPanel     :", address(ap));
        console.log("AdminPanelFixed:", address(apf));
        console.log("SigVault       :", address(sv));
        console.log("SigVaultFixed  :", address(svf));
        console.log("Auction        :", address(auction));
        console.log("AuctionFixed   :", address(auctionFixed));
    }
}
