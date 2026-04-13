// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract SubscriptionCreator is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
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

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkTokenAddress = helperConfig.getConfig().linkToken;

        fundSubscription(vrfCoordinator, subscriptionId, linkTokenAddress);
    }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkTokenAddress
    ) public {
        if (block.chainid == LOCALHOST_CHAINID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
            console.log("Subscription funded with amount:", FUND_AMOUNT);
        } else {
            vm.startBroadcast();
            LinkToken(linkTokenAddress).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
            console.log("Subscription funded with amount:", FUND_AMOUNT);
        }
    }
}
