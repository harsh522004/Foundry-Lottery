// SPDX-License-Idnetifier: MIT
pragma solidity ^0.8.18;

// IMPORTS
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// Custom error
error Raffle_NotEnoughEthSent();

/**
 * @title A sample Raffle Contract
 * @author Harsh Butani
 * @notice This contract is for creating a sample raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */
contract Raffle is VRFConsumerBaseV2Plus {

    // State Variables
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 public s_subscriptionId;
    uint256 private s_lastTimeStamp;

    // Events
    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval, uint256 subscriptionId)
    VRFConsumerBaseV2Plus(0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        s_subscriptionId = subscriptionId;
    }

    function enterRaffle() external payable{
        if(msg.value < i_entranceFee) revert Raffle__NotEnoughEthSent();
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }
    
    function pickWinner() public {
        if(block.timestamp - s_lastTimeStamp < i_interval) revert();
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
                        VRFV2PlusClient.RandomWordsRequest({
                            keyHash: keyHash,
                            subId: s_subscriptionId,
                            requestConfirmations: requestConfirmations,
                            callbackGasLimit: callbackGasLimit,
                            numWords: numWords,
                            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: enableNativePayment}))
                        })
    );
    }

    // Getter Function
    function getEntranceFee() external view returns (uint256){
        return i_entranceFee;
    }
}