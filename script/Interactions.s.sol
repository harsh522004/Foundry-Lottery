// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract SubscriptionCreator is Script {
    function createSubscription(
        address vrfCoordinator
    ) public returns (uint256, address) {
        vm.startBroadcast();
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Subscription created with ID:", subscriptionId);
        return (subscriptionId, vrfCoordinator);
    }

    function run() external returns (uint64) {
        // create subscription using config
    }
}

contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 3 ether;

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkTokenAddress
    ) public {
        if (block.chainid == LOCALHOST_CHAINID) {
            vm.startBroadcast();
            vm.deal(msg.sender, FUND_AMOUNT);
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscriptionWithNative{
                value: FUND_AMOUNT
            }(subscriptionId);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(linkTokenAddress).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address vrfCoordinator,
        uint256 subscriptionId,
        address consumerAddress
    ) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subscriptionId,
            consumerAddress
        );
        vm.stopBroadcast();
        console.log("Consumer added to subscription:", consumerAddress);
    }
}
