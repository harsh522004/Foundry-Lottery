// SPDX-License-Identifier : MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";

// contract for constant
abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAINID = 11155111;
    uint256 public constant LOCALHOST_CHAINID = 31337;
}

contract HelperConfig is Script {

    error HelperConfig_ChainIdNotFound(uint256 chainId);
     
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }

    // variables
    NetworkConfig public activeNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfig;

    constructor() {
        networkConfig[ETH_SEPOLIA_CHAINID] = getSepoliaEthConfig();
        activeNetworkConfig = networkConfig[block.chainid];
    }

    function getConfigByChainId(uint256 chainId) public view returns (NetworkConfig memory) {
        if (networkConfig[chainId].vrfCoordinator != address(0)) {
            return networkConfig[chainId];
        } else if (chainId == LOCALHOST_CHAINID) {
            return getOrCreateAnvilEthConfig();
        } 
        else {
            revert HelperConfig_ChainIdNotFound(chainId);
        }
    }

    funtion getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000
        });
        return sepoliaConfig;
    }
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }
        // create a new subscription
        vm.startBroadcast();
        uint64 subscriptionId = VRFCoordinatorV2Mock.createSubscription();
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(VRFCoordinatorV2Mock),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: subscriptionId,
            callbackGasLimit: 500000
        });
        return anvilConfig;
}
