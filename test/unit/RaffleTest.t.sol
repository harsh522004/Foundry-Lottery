// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

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

    // Events
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    // Modifiers
    modifier raffleEntredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1); // Manipulate block timestamp
        vm.roll(block.number + 1); // add a new block to update the timestamp
        _;
    }

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

    /*//////////////////////////////////////////////////////////////
                        enterRaffle() Tests
    //////////////////////////////////////////////////////////////*/

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

    // Testing : enterRaffle() - to verify that the function reverts if the raffle is not open
    function testEnterRaffleWhenNotOpen() public raffleEntredAndTimePassed {
        // Arrange
        raffle.performUpkeep("");

        // Act and Assert
        vm.expectRevert(Raffle.Raffle_NotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    /*//////////////////////////////////////////////////////////////
                        checkUpkeep() Tests
    //////////////////////////////////////////////////////////////*/

    // Testing : checkUpkeep() - to verify that it returns false if there are no players
    function testCheckUpkeepReturnsFalseIfNoPlayers() public {
        // Arrange
        vm.warp(block.timestamp + interval + 1); // Manipulate block timestamp
        vm.roll(block.number + 1); // add a new block to update the timestamp

        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        // Assert
        assertFalse(
            upkeepNeeded,
            "checkUpkeep should return false if there are no players"
        );
    }

    // Testing : checkUpkeep() - to verify that it returns false if the raffle is not open
    function testCheckUpkeepReturnsFalseIfRaffleNotOpen()
        public
        raffleEntredAndTimePassed
    {
        // Arrange
        raffle.performUpkeep(""); // This will change the raffle state to CALCULATING

        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        // Assert
        assertFalse(
            upkeepNeeded,
            "checkUpkeep should return false if the raffle is not open"
        );
    }

    // Testing : checkUpkeep() - to verify that it returns true if the time interval has passed, there are players, and the raffle is open
    function testCheckUpkeepReturnsTrue() public raffleEntredAndTimePassed {
        // Arrange

        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        // Assert
        assertTrue(
            upkeepNeeded,
            "checkUpkeep should return true if the time interval has passed, there are players, and the raffle is open"
        );
    }

    /*//////////////////////////////////////////////////////////////
                         performUpKeep()
    //////////////////////////////////////////////////////////////*/

    // Testing : only run if checkUpKeep Return true
    function testPerformUpKeepOnlyRunWhenCheckUpKeepIsTrue()
        public
        raffleEntredAndTimePassed
    {
        // Arrange

        // Act & Assert
        raffle.performUpkeep("");
    }

    // Testing : not run when checkUpKeep return false
    function testPerformUpKeepOnlyRunWhenCheckUpKeepIsFalse() public {
        // Arrange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        // No need to arrange to test properly

        // Act & Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle_UpKeepNotNeeded.selector,
                currentBalance,
                numPlayers,
                raffleState
            )
        );
        raffle.performUpkeep("");
    }

    // Testing : check event trigger on PerformUpkeep
    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId()
        public
        raffleEntredAndTimePassed
    {
        // Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        // Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint(raffleState) == 1);
    }

    /*//////////////////////////////////////////////////////////////
                        Fuzz() Tests
    //////////////////////////////////////////////////////////////*/

    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep()
        public
        raffleEntredAndTimePassed
    {
        // Arrange
        // Act / Assert
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            randomRequestId,
            address(raffle)
        );
    }
}
