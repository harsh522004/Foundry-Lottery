// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

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
        (raffle, helperConfig) = deployer.deployContract();

        HelperConfig.NetworkConfig memory activeNetworkConfig = helperConfig
            .getConfig();
        entranceFee = activeNetworkConfig.entranceFee;
        interval = activeNetworkConfig.interval;
        vrfCoordinator = activeNetworkConfig.vrfCoordinator;
        gasLane = activeNetworkConfig.gasLane;
        subscriptionId = activeNetworkConfig.subscriptionId;
        callbackGasLimit = activeNetworkConfig.callbackGasLimit;

        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
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

    // Testing : enterRaffle() with NOT enough ETH
    function testEnterRaffleWithNotEnoughEth() public {
        // Arrange
        uint256 notEnoughEth = entranceFee - 1;

        vm.prank(PLAYER);

        // Act & Assert
        vm.expectRevert(Raffle.Raffle_NotEnoughEthSent.selector);
        raffle.enterRaffle{value: notEnoughEth}();
    }

    // Testing : enterRaffle() - to vefify that the player is added to the players array
    function testEnterRaffleAddsPlayer() public {
        // Arrange
        vm.prank(PLAYER);

        // Act
        raffle.enterRaffle{value: entranceFee}();

        // Assert
        address expectedPlayer = PLAYER;
        address actualPlayer = raffle.getPlayer(0);
        assertEq(
            actualPlayer,
            expectedPlayer,
            "Player was not added to the players array"
        );
    }

    // Testing : enterRaffle() - to verify that the EnteredRaffle event is emitted with the correct player address
    function testEnterRaffleEmitsEvent() public {
        // Arrange
        vm.prank(PLAYER);

        // Act & Assert
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }
}
