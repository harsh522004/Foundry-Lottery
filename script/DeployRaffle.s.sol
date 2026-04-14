// SPDX-License-Identifier : MIT
pragma solidity ^0.8.19;

import {HelperConfig} from "./HelperConfig.s.sol";
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {SubscriptionCreator, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    function run() public {}

    function deployContract() public returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory activeNetworkConfig = helperConfig
            .getConfig();

        if (activeNetworkConfig.subscriptionId == 0) {
            // create subscription using config
            SubscriptionCreator subscriptionCreator = new SubscriptionCreator();
            (
                uint256 newSubscriptionId,
                address vrfCoordinator
            ) = subscriptionCreator.createSubscriptionUsingConfig();
            activeNetworkConfig.subscriptionId = newSubscriptionId;
            activeNetworkConfig.vrfCoordinator = vrfCoordinator;

            // fund subscription using config
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                activeNetworkConfig.vrfCoordinator,
                activeNetworkConfig.subscriptionId,
                activeNetworkConfig.linkToken
            );
        }
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

        // add consumer using config
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            activeNetworkConfig.vrfCoordinator,
            activeNetworkConfig.subscriptionId,
            address(raffle)
        );

        return (raffle, helperConfig);
    }
}
