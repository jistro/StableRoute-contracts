// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {L2Registrar} from "../src/L2Registrar.sol";

contract L2RegistrarScript is Script {
    L2Registrar public registrar;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        registrar = new L2Registrar(0x1035E9A680F6A7bF051C72e42DE70dB297bDB970);

        vm.stopBroadcast();
    }
}
