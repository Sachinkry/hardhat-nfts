// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error AlreadyInitialized();
error NeedMoreETHSent();
error RangeOutOfBounds();
error RandomIpfsNft__TransferFailed();

contract RandomIpfsNFT is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
    // when we mint an NFT, we would request chainlink vrf to get us a random number
    // using that randNum to provide randomNFT
    // Pug, Shiba, St. bernan
    // Pug super rare
    // Shiba sort of rare
    // St. bernan common

    // users have to pay to get an NFT
    // the owner can withdraw the payments

    // Type Declaration
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callBackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // VRF Helpers
    mapping (uint256 => address) public s_requestIdToSender;


    // NFT Variables
    uint256 public s_tokenCounter;
    uint256 internal constant MAX_CHANCE_VALUE = 100;
    string[] internal s_dogTokenUris;
    uint256 internal immutable i_mintFee;
    bool private s_initialized;

    // Events
    event NftRequested(uint256 indexed requesId, address requester);
    event NftMinted(Breed breed, address minter);

    constructor(
        address vrfCoordinatorV2
        uint64 subscriptionId,
        bytes32 gasLane, // keyHash
        uint32 callbackGasLimit,
        string[3] memory dogTokenUris,
        uint256 mintFee
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random IPFS NFT", "RIN") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_callBackGasLimit = callbackGasLimit;
        i_mintFee = mintFee;
        _initializeContract(dogTokenUris);

    }
    
    function requestNFT() public payable returns (uint256 requesId) {
        if(msg.value < i_mintFee){
            revert NeedMoreETHSent();
        }
        requesId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callBackGasLimit,
            NUM_WORDS
        );

        s_requestIdToSender[requesId] = msg.sender;
        emit NftRequested(requesId, msg.sender);
    }

    function fulfillRandomWords(uint256 requesId, uint256[] memory randomWords) internal override {
        address dogOwner = s_requestIdToSender[requesId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;
        // what does this token look like?
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        // 0 - 99
        // 7 -> PUG
        // 12 -> Shiba Inu
        // 88 -> St. Bernard
        // 34 -> St. Bernard

        Breed dogBreed = getBreedFromModdedRng(moddedRng);
        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUris[uint256(dogBreed)]);
        emit NftMinted(dogBreed, dogOwner);
    }

    function getBreedFromModdedRng(uint256 moddedRng) public returns (Breed) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        // moddedRng = 25
        // i = 0
        // cumulativeSum = 0
        for(uint256 i = 0; i < chanceArray.length; i++) {
            // Pug = 0 - 9 (10%)
            // Shiba-inu = 10 - 39 (30%)
            // St. Bernard = 40 - 99 (60%)
            if(moddedRng >= cumulativeSum && moddedRng < chanceArray[i] {
                return Breed(i);
            }
            cumulativeSum = chanceArray[i]
        }
        revert RangeOutOfBounds();
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function _initializeContract(string[3] memory dogTokenUris) private {
        if(s_initialized) {
            revert AlreadyInitialized();
        }
        s_dogTokenUris = dogTokenUris;
        s_initialized = true;
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if(!success) {
            revert RandomIpfsNft__TransferFailed();
        }
    }

    function getMintfee() public view returns (uint256) {
        return i_mintFee;
    }

    function getDogTokenUris(uint256 index) public view returns (string memory){
        return s_dogTokenUris[index];
    }

    function getInitialized() public view returns (bool) {
        return s_initialized();
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}