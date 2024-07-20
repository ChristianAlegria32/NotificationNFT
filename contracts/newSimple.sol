// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NotificationNFT is ERC721Enumerable, Ownable {
    uint256 private _nextTokenId;
    
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public mintPrice = 0.05 ether;
    string public baseTokenURI;

    mapping(uint256 => string) private _tokenURIs;

    event NFTMinted(address indexed minter, uint256 indexed tokenId, string tokenURI);

    constructor(string memory initialBaseURI, address initialOwner) 
        ERC721("NotificationNFT", "NNFT") 
        Ownable(initialOwner)
    {
        baseTokenURI = initialBaseURI;
    }

    function mintNFT(string memory _tokenURI) public payable returns (uint256) {
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");

        uint256 newTokenId = _nextTokenId++;
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);

        emit NFTMinted(msg.sender, newTokenId, _tokenURI);

        return newTokenId;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseTokenURI;

        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        } else if (bytes(base).length > 0) {
            return string(abi.encodePacked(base, tokenId));
        } else {
            return "";
        }
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseTokenURI = _newBaseURI;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
}