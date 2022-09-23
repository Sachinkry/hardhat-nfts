// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNFT is ERC721 {
    uint256 private tokenCounter;
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    constructor() ERC721("Doggie", "DOGGIE") {
        tokenCounter = 0;
    }

    // mint function
    function mint() public {
        tokenCounter += 1;
        _safeMint(msg.sender, tokenCounter);
    }

    // tokenURI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return TOKEN_URI;
    } 

    // return tokenId
    function getTokenCounter() public returns (uint256) {
        return tokenCounter;
    }
}