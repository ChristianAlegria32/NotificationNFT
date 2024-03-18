// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title NFT Storage and Transfer Contract
/// @dev Contract to store NFTs against an email and allow claiming of NFTs to a wallet address associated with an email.
contract NFTStorageAndTransfer is ReentrancyGuard {
    address owner;

    /// @dev Maps email hash to wallet address for linked emails.
    mapping(bytes32 => address) private emailToAddress;

    /// @dev Maps NFT ID to email hash for stored NFTs.
    mapping(uint256 => bytes32) private nftToEmailHash;

    /// @notice Emitted when an NFT is stored with an email.
    /// @param nftContract The address of the NFT contract.
    /// @param tokenId The token ID of the stored NFT.
    /// @param email The email with which the NFT is associated.
    event NFTStored(address indexed nftContract, uint256 tokenId, string email);

    /// @notice Emitted when an NFT is transferred from the contract to a user.
    /// @param nftContract The address of the NFT contract.
    /// @param from The address from which the NFT is transferred.
    /// @param to The address to which the NFT is transferred.
    /// @param tokenId The token ID of the transferred NFT.
    event NFTTransferred(
        address indexed nftContract,
        address indexed from,
        address indexed to,
        uint256 tokenId
    );

    /// @notice Emitted when an email is linked to an address.
    /// @param email The email that is linked.
    /// @param addr The address to which the email is linked.
    event EmailLinked(string email, address addr);

    /// @dev Modifier to allow only the owner to execute a function.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /// @notice Initializes the contract setting the deployer as the owner.
    constructor() {
        owner = msg.sender;
    }

    /// @notice Links an email to a wallet address.
    /// @dev Can only be called by the owner of the contract.
    /// @param email The email to link.
    /// @param addr The address to link to the email.
    function linkEmailToAddress(
        string memory email,
        address addr
    ) public onlyOwner {
        bytes32 emailHash = keccak256(abi.encodePacked(email));
        emailToAddress[emailHash] = addr;
        emit EmailLinked(email, addr);
    }

    /// @notice Stores an NFT against an email.
    /// @dev The caller must own the NFT and the NFT must be transferable to the contract.
    /// @param _nftContract The address of the NFT contract.
    /// @param _tokenId The token ID of the NFT.
    /// @param email The email against which the NFT will be stored.
    function storeNFT(
        address _nftContract,
        uint256 _tokenId,
        string memory email
    ) public nonReentrant {
        bytes32 emailHash = keccak256(abi.encodePacked(email));
        require(
            IERC721(_nftContract).ownerOf(_tokenId) == msg.sender,
            "Caller is not the owner"
        );
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        nftToEmailHash[_tokenId] = emailHash;
        emit NFTStored(_nftContract, _tokenId, email);
    }

    /// @notice Claims a stored NFT to the caller's address.
    /// @dev The caller's address must be linked to the email associated with the stored NFT.
    /// @param _nftContract The address of the NFT contract.
    /// @param _tokenId The token ID of the NFT.
    /// @param recipientEmail The email associated with the stored NFT.
    function claimStoredNFT(
        address _nftContract,
        uint256 _tokenId,
        string memory recipientEmail
    ) public nonReentrant {
        bytes32 emailHash = keccak256(abi.encodePacked(recipientEmail));
        require(
            emailToAddress[emailHash] == msg.sender,
            "Email not linked to caller"
        );
        require(
            nftToEmailHash[_tokenId] == emailHash,
            "NFT not stored for this email"
        );

        IERC721(_nftContract).transferFrom(address(this), msg.sender, _tokenId);
        emit NFTTransferred(_nftContract, address(this), msg.sender, _tokenId);

        // Remove the NFT from storage mapping after successful claim
        delete nftToEmailHash[_tokenId];
    }

    /// @notice Transfers an NFT to an address associated with the recipient's email.
    /// @dev The recipient's email must be linked to an address and the caller must own the NFT.
    /// @param _nftContract The address of the NFT contract.
    /// @param recipientEmail The recipient's email linked to their address.
    /// @param _tokenId The token ID of the NFT.
    function transferNFT(
        address _nftContract,
        string memory recipientEmail,
        uint256 _tokenId
    ) public nonReentrant {
        bytes32 emailHash = keccak256(abi.encodePacked(recipientEmail));
        address recipientAddress = emailToAddress[emailHash];
        require(recipientAddress != address(0), "Recipient email not linked");

        IERC721(_nftContract).transferFrom(
            msg.sender,
            recipientAddress,
            _tokenId
        );
        emit NFTTransferred(
            _nftContract,
            msg.sender,
            recipientAddress,
            _tokenId
        );
    }
}
