// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Voucher} from "../src/Voucher.sol";

contract VoucherScript is Script {
    Voucher public voucher;

    address constant USDC = 0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d;
    address constant SUDO_ACCOUNT = 0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        voucher = new Voucher(
            USDC,
            SUDO_ACCOUNT
        );
        

        vm.stopBroadcast();
    }
}
