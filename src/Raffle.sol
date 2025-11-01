//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 *  Custom Errors
 */

error Raffle__NotEnoughEthSent();
error Raffle__TransferFailed();
error Raffle__RaffleIsNotOpen();

/**
 * @title Raffle Contract
 * @author Ebin Yesudas
 * @notice This contract is for creating Lotteries.
 * @dev Implements chainlink VRF
 */

contract Raffle is VRFConsumerBaseV2Plus {

    /** Type Declarations */

    enum RaffleStatus {
        OPEN,
        CALCULATING
    }


    /** State Variables */

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    /**
     * @dev i_raffleInterval stores the raffle duration in seconds
     */
    uint256 private immutable i_raffleInterval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    address payable[] private s_players;
    uint256 private s_createdTimestamp;
    address private s_recentWinner;
    RaffleStatus private s_raffleStatus;

    
    /**
     * Events
     */

    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_raffleInterval = interval;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_createdTimestamp = block.timestamp;
        s_raffleStatus = RaffleStatus.OPEN;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        if(s_raffleStatus != RaffleStatus.OPEN) revert Raffle__RaffleIsNotOpen();
        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {
        if (block.timestamp - s_createdTimestamp < i_raffleInterval) revert();
        s_raffleStatus = RaffleStatus.CALCULATING;
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleStatus = RaffleStatus.OPEN;
        s_players = new address payable[](0);
        s_createdTimestamp = block.timestamp;
        emit WinnerPicked(winner);
        
        (bool success,) = winner.call{value:address(this).balance}("");
        if(!success){
            revert Raffle__TransferFailed();
        }
    }

    /**
     * Getter Functions
     */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayers(uint256 index) external view returns (address) {
        return s_players[index];
    }
}
