// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/// @title NFT Custody Service Contract
/// @dev This contract allows users to deposit NFTs into custody and later claim them.
contract NFTCustody is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    error CallerNotMinter(address caller);

    mapping(string => uint256[]) private _ownedNFTs;
    mapping(uint256 => address) private _nftContracts;
    mapping(uint256 => string) private _positions;
    mapping(uint256 => string) private _teams;
    mapping(uint256 => uint256) private _scores;
    mapping(uint256 => string) private _tokenURIs;

    /// @notice Constructs the NFTCustody contract and initializes the token with name and symbol.
    constructor(address minter) ERC721("NFTCustody", "NFTC") {
        _grantRole(MINTER_ROLE, minter);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl) returns (bool) {
        return
            ERC721.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }

    /// @notice Deposits an NFT into custody under a user's ID.
    /// @dev Transfers the NFT from the caller's address to this contract.
    /// @param userId The user ID to which the NFT will be associated.
    /// @param tokenId The token ID of the NFT.
    /// @param nftContractAddress The address of the NFT contract.
    function depositNFT(
        string memory userId,
        uint256 tokenId,
        address nftContractAddress
    ) public {
        IERC721 nftContract = IERC721(nftContractAddress);

        if (!hasRole(MINTER_ROLE, msg.sender)) {
            revert CallerNotMinter(msg.sender);
        }

        require(
            nftContract.getApproved(tokenId) == address(this),
            "NFT must be approved for transfer"
        );

        nftContract.transferFrom(msg.sender, address(this), tokenId);

        _ownedNFTs[userId].push(tokenId);
        _nftContracts[tokenId] = nftContractAddress;

        emit NFTDeposited(userId, tokenId, nftContractAddress);
    }

    /// @notice Claims all NFTs held in custody for a user ID.
    /// @dev Transfers all NFTs associated with the user ID to a specified wallet.
    /// @param userId The user ID whose NFTs are being claimed.
    /// @param userWallet The wallet address to which the NFTs will be transferred.
    /// @param position The position of the user.
    /// @param team The team of the user.
    /// @param score The score of the user.
    /// @param metadataURI The metadata URI of the NFT.
    function claimNFT(
        string memory userId,
        address userWallet,
        string memory position,
        string memory team,
        uint256 score,
        string memory metadataURI
    ) public {
        if (!hasRole(MINTER_ROLE, msg.sender)) {
            revert CallerNotMinter(msg.sender);
        }

        require(_ownedNFTs[userId].length > 0, "User has no NFTs to claim");

        for (uint i = 0; i < _ownedNFTs[userId].length; i++) {
            uint256 tokenId = _ownedNFTs[userId][i];
            address nftContractAddress = _nftContracts[tokenId];
            IERC721 nftContract = IERC721(nftContractAddress);

            _positions[tokenId] = position;
            _teams[tokenId] = team;
            _scores[tokenId] = score;
            _tokenURIs[tokenId] = metadataURI;

            nftContract.transferFrom(address(this), userWallet, tokenId);

            emit NFTClaimed(userId, tokenId, nftContractAddress, userWallet, position, team, score, metadataURI);
        }

        delete _ownedNFTs[userId];
    }

    /// @notice Returns the metadata URI for a given token ID.
    /// @param tokenId The ID of the token.
    /// @return The metadata URI of the token.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{"name": "NFT #', Strings.toString(tokenId), '",',
            '"description": "An NFT from NFTCustody contract.",',
            '"attributes": [',
            '{"trait_type": "Position", "value": "', _positions[tokenId], '"},',
            '{"trait_type": "Team", "value": "', _teams[tokenId], '"},',
            '{"trait_type": "Score", "value": ', Strings.toString(_scores[tokenId]), '}',
            '],',
            '"image": "', _tokenURIs[tokenId], '"}'
        ))));
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    /// @dev Emitted when an NFT is deposited into custody.
    /// @param userId The ID of the user who deposited the NFT.
    /// @param tokenId The token ID of the deposited NFT.
    /// @param nftContractAddress The contract address of the deposited NFT.
    event NFTDeposited(
        string indexed userId,
        uint256 indexed tokenId,
        address indexed nftContractAddress
    );

    /// @dev Emitted when a user claims their NFTs from custody.
    /// @param userId The ID of the user claiming the NFTs.
    /// @param tokenId The token ID of the NFT being claimed.
    /// @param nftContractAddress The contract address of the NFT being claimed.
    /// @param userWallet The wallet address to which the NFTs are being transferred.
    /// @param position The position of the user.
    /// @param team The team of the user.
    /// @param score The score of the user.
    /// @param tokenURI The metadata URI of the NFT.
    event NFTClaimed(
        string indexed userId,
        uint256 indexed tokenId,
        address nftContractAddress,
        address indexed userWallet,
        string position,
        string team,
        uint256 score,
        string tokenURI
    );
}
