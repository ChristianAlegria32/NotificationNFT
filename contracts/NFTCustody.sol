// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTCustody is ERC721 {
    // A user's ID mapped to their list of NFT tokenIds
    mapping(string => uint256[]) private _ownedNFTs;

    // Mapping from tokenId to the NFT contract address
    mapping(uint256 => address) private _nftContracts;

    constructor() ERC721("NFTCustody", "NFTC") {}

    function depositNFT(string memory userId, uint256 tokenId, address nftContractAddress) public {
        // The NFT contract
        IERC721 nftContract = IERC721(nftContractAddress);

        // Check that the NFT is approved for transfer to this contract
        require(nftContract.getApproved(tokenId) == address(this), "NFT must be approved for transfer");

        // Transfer the NFT to this contract
        nftContract.transferFrom(msg.sender, address(this), tokenId);

        // Record the deposit in the mappings
        _ownedNFTs[userId].push(tokenId);
        _nftContracts[tokenId] = nftContractAddress;

        // Emit an event for the deposit
        emit NFTDeposited(userId, tokenId, nftContractAddress);
    }

    function claimNFT(string memory userId, address userWallet) public {
        // Assuming a user can only claim all NFTs at once for simplicity
        require(_ownedNFTs[userId].length > 0, "User has no NFTs to claim");

        // Transfer all NFTs to the userWallet
        for (uint i = 0; i < _ownedNFTs[userId].length; i++) {
            uint256 tokenId = _ownedNFTs[userId][i];
            address nftContractAddress = _nftContracts[tokenId];

            // The NFT contract
            IERC721 nftContract = IERC721(nftContractAddress);

            // Transfer the NFT to the user's wallet
            nftContract.transferFrom(address(this), userWallet, tokenId);

            // Emit an event for the claim
            emit NFTClaimed(userId, tokenId, nftContractAddress, userWallet);
        }

        // Reset the user's NFT list
        delete _ownedNFTs[userId];
    }

    // Event to emit when an NFT is deposited
    event NFTDeposited(string indexed userId, uint256 indexed tokenId, address indexed nftContractAddress);

    // Event to emit when an NFT is claimed
    event NFTClaimed(string indexed userId, uint256 indexed tokenId, address nftContractAddress, address indexed userWallet);

    
}