// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract ChainlinkVRFTest is VRFConsumerBaseV2Plus {
    /*
     *  Events
     */
    event Announce(address indexed winner, uint256 value);
    event DiceRolled(uint256 indexed requestId);
    event DiceLanded(uint256 indexed requestId, uint256 indexed result);
    /*
     *  Constants
     */

    /*
     *  Storage
     */
    uint256 immutable i_subscriptionId;
    bytes32 s_keyHash =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 callbackGasLimit = 40000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    address immutable i_owner;
    uint256 randomNum;
    /*
     *  Modifiers
     */

    // modifier onlyOwner() {
    //     require(msg.sender == i_owner);
    //     _;
    // }

    /// @dev Fallback function allows to deposit ether.
    receive() external payable {}

    fallback() external {}

    /*
     * Public functions
     */
    /// @dev Contract constructor .
    constructor(uint256 subscriptionId) VRFConsumerBaseV2Plus(address vrfCoordinator) {
        i_subscriptionId = subscriptionId;
        i_owner = msg.sender;
    }
    function rollDice() public onlyOwner returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        emit DiceRolled(requestId);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        // transform the result to a number between 1 and 20 inclusively
        uint256 d20Value = (randomWords[0] % 20) + 1;

        // assign the transformed value to the address in the s_results mapping variable
        s_results[s_rollers[requestId]] = d20Value;

        // emitting event to signal that dice landed
        emit DiceLanded(requestId, d20Value);
    }

    /// @dev Returns owner.
    /// @return i_owner address.
    function getOwners() public view returns (address) {
        return i_owner;
    }

    /// @dev Returns Random Number.
    /// @return randomNum Returns randomNum.
    function getRandomNumber() public view returns (uint) {
        return randomNum;
    }
}
