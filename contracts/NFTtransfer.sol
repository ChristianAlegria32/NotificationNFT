// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFTStorageAndTransfer is ReentrancyGuard {
    address owner;
    mapping(bytes32 => address) private emailToAddress; // Maps email hash to wallet address
    mapping(uint256 => bytes32) private nftToEmailHash; // Maps NFT ID to email hash for stored NFTs

    event NFTStored(address indexed nftContract, uint256 tokenId, string email);
    event NFTTransferred(address indexed nftContract, address indexed from, address indexed to, uint256 tokenId);
    event EmailLinked(string email, address addr);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function linkEmailToAddress(string memory email, address addr) public onlyOwner {
        bytes32 emailHash = keccak256(abi.encodePacked(email));
        emailToAddress[emailHash] = addr;
        emit EmailLinked(email, addr);
    }

    function storeNFT(address _nftContract, uint256 _tokenId, string memory email) public nonReentrant {
        bytes32 emailHash = keccak256(abi.encodePacked(email));
        require(IERC721(_nftContract).ownerOf(_tokenId) == msg.sender, "Caller is not the owner");
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        nftToEmailHash[_tokenId] = emailHash;
        emit NFTStored(_nftContract, _tokenId, email);
    }

    function claimStoredNFT(address _nftContract, uint256 _tokenId, string memory recipientEmail) public nonReentrant {
        bytes32 emailHash = keccak256(abi.encodePacked(recipientEmail));
        require(emailToAddress[emailHash] == msg.sender, "Email not linked to caller");
        require(nftToEmailHash[_tokenId] == emailHash, "NFT not stored for this email");

        IERC721(_nftContract).transferFrom(address(this), msg.sender, _tokenId);
        emit NFTTransferred(_nftContract, address(this), msg.sender, _tokenId);

        // Remove the NFT from storage mapping after successful claim
        delete nftToEmailHash[_tokenId];
    }

    function transferNFT(address _nftContract, string memory recipientEmail, uint256 _tokenId) public nonReentrant {
        bytes32 emailHash = keccak256(abi.encodePacked(recipientEmail));
        address recipientAddress = emailToAddress[emailHash];
        require(recipientAddress != address(0), "Recipient email not linked");

        IERC721(_nftContract).transferFrom(msg.sender, recipientAddress, _tokenId);
        emit NFTTransferred(_nftContract, msg.sender, recipientAddress, _tokenId);
    }
}
