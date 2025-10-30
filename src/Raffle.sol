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

    constructor(uint256 entranceFee){
        i_entranceFee = entranceFee;
    }


    function enterRaffle() public payable{
        if(msg.value < i_entranceFee){
            revert Raffle_NotEnoughEthSent();
        }
    }

    function pickWinner() public {}


    /** Getter Functions */ 

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
}