// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract VaultScript is Script {
    Vault public vault;

    address constant USDC = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    address constant SUDO_ACCOUNT = 0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309;
    address constant TOKEN_MESSENGER = 0x8FE6B999Dc680CcFDD5Bf7EB0974218be2542DAA;
    address constant VOUCHER_ADDRESS = 0x101a92a3C5A330eE310BBe7246287d27487d2E32; // Replace with actual voucher address
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vault = new Vault(
            USDC,
            TOKEN_MESSENGER,
            SUDO_ACCOUNT,
            VOUCHER_ADDRESS
        );
        

        vm.stopBroadcast();
    }
}
