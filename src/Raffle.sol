//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


/** Custom Errors */

error Raffle_NotEnoughEthSent();


/**
 * @title Raffle Contract
 * @author Ebin Yesudas
 * @notice This contract is for creating Lotteries.
 * @dev Implements chainlink VRF
 */

contract Raffle{
    uint256 private immutable i_entranceFee;
    /**@dev i_raffleInterval stores the raffle duration in seconds */
    uint256 private immutable i_raffleInterval; 
    uint256 private immutable i_createdTimestamp;
    address payable[] private s_players;


    /** Events */

    event RaffleEntered(address indexed player);


    constructor(uint256 entranceFee, uint256 interval){
        i_entranceFee = entranceFee;
        i_raffleInterval = interval;
        i_createdTimestamp = block.timestamp;
    }


    function enterRaffle() public payable{
        if(msg.value < i_entranceFee){
            revert Raffle_NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {
        if(block.timestamp-i_createdTimestamp < i_raffleInterval) revert();
    }


    /** Getter Functions */ 

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }

    function getPlayers(uint256 index) external view returns(address){
        return s_players[index];
    }
}