// SPDX-License-Identifier : MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

// contract for constant
abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAINID = 11155111;
    uint256 public constant LOCALHOST_CHAINID = 31337;
    uint96 public constant BASE_FEE = 0.25 ether;
    uint96 public constant GAS_PRICE_LINK = 1e9; // 0.000000001 LINK per gas
    int256 public constant WEI_PER_UNIT_LINK = 4e15; // 0.004 ETH per LINK
}

contract HelperConfig is Script, CodeConstants {
    error HelperConfig_ChainIdNotFound(uint256 chainId);

    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address linkToken;
    }

    // variables
    NetworkConfig public activeNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfig;

    constructor() {
        networkConfig[ETH_SEPOLIA_CHAINID] = getSepoliaEthConfig();
        activeNetworkConfig = networkConfig[block.chainid];
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(
        uint256 chainId
    ) public returns (NetworkConfig memory) {
        if (networkConfig[chainId].vrfCoordinator != address(0)) {
            return networkConfig[chainId];
        } else if (chainId == LOCALHOST_CHAINID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig_ChainIdNotFound(chainId);
        }
    }

    function getSepoliaEthConfig()
        internal
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig()
        internal
        returns (NetworkConfig memory)
    {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(
                BASE_FEE,
                GAS_PRICE_LINK,
                WEI_PER_UNIT_LINK
            );
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();

        // deploy our own LINK token and set the address here if needed

        NetworkConfig memory anvilConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorV2_5Mock),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,
            callbackGasLimit: 500000,
            linkToken: address(linkToken)
        });

        activeNetworkConfig = anvilConfig;
        networkConfig[LOCALHOST_CHAINID] = anvilConfig;
        return activeNetworkConfig;
    }
}
