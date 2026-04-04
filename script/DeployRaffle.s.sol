import {HelperConfig} from "./HelperConfig.s.sol";

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
