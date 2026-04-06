// SPDX-License-Identifier : MIT
pragma solidity ^0.8.18;

import {HelperConfig} from "./HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link
        ) = helperConfig.getConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            vrfCoordinator,
            helperConfig.entranceFee(),
            interval,
            subscriptionId,
            callbackGasLimit,
            gasLane
        );
        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}
