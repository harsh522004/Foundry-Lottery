// SPDX-License-Identifier : MIT
pragma solidity ^0.8.19;

import {HelperConfig} from "./HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory activeNetworkConfig = helperConfig
            .getConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            activeNetworkConfig.vrfCoordinator,
            activeNetworkConfig.entranceFee,
            activeNetworkConfig.interval,
            activeNetworkConfig.subscriptionId,
            activeNetworkConfig.callbackGasLimit,
            activeNetworkConfig.gasLane
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}
