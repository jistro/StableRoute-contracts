// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ProofOfHuman} from "../src/ProofOfHuman.sol";

contract ProofOfHumanScript is Script {
    ProofOfHuman public proofOfHuman;
    address constant identityVerificationHubV2Address =
        0x68c931C9a534D37aa78094877F46fE46a49F1A51; // Replace with actual address

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        proofOfHuman = new ProofOfHuman(identityVerificationHubV2Address);

        vm.stopBroadcast();
    }
}
