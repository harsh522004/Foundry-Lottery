// SPDX-License-Idnetifier: MIT
pragma solidity ^0.8.18;


// Custom error
error Raffle_NotEnoughEthSent();

/**
 * @title A sample Raffle Contract
 * @author Harsh Butani
 * @notice This contract is for creating a sample raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */
contract Raffle{

    // State Variables
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;

    // Events
    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval){
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable{
        if(msg.value < i_entranceFee) revert Raffle__NotEnoughEthSent();
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }
    
    function pickWinner() public {
        if(block.timestamp - s_lastTimeStamp < i_interval) revert();
    }

    // Getter Function
    function getEntranceFee() external view returns (uint256){
        return i_entranceFee;
    }
}