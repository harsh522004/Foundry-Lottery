// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";

contract RaffleTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    address public PLAYER = makeAddr("player");

    uint256 public entranceFee;
    uint256 public interval;
    address public vrfCoordinator;
    bytes32 public gasLane;
    uint256 public subscriptionId;
    uint32 public callbackGasLimit;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();

        vm.deal(PLAYER, STARTING_USER_BALANCE);
        (
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            entranceFee
        ) = helperConfig.getConfig();
    }

    function testRaffleInitializesInOpenState() external {
        // Arrange
        Raffle.RaffleState expectedState = Raffle.RaffleState.OPEN;

        // Act
        Raffle.RaffleState actualState = raffle.getRaffleState();

        // Assert
        assertEq(
            uint256(actualState),
            uint256(expectedState),
            "Raffle did not initialize in OPEN state"
        );
    }
}
