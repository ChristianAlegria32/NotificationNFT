import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";

describe("NFTStorageAndTransfer", function () {
  let nftStorageAndTransfer: Contract;
  let mockNFT: Contract;
  let deployer: Signer, user1: Signer, user2: Signer;

  beforeEach(async function () {
    [deployer, user1, user2] = await ethers.getSigners();

    const MockNFT = await ethers.getContractFactory("MockNFT");
    mockNFT = await MockNFT.deploy();
    await mockNFT.deployed();

    const NFTStorageAndTransfer = await ethers.getContractFactory("NFTStorageAndTransfer");
    nftStorageAndTransfer = await NFTStorageAndTransfer.deploy();
    await nftStorageAndTransfer.deployed();
  });

  describe("Email Linking", function () {
    it("should allow the owner to link an email to an address", async function () {
      await expect(nftStorageAndTransfer.linkEmailToAddress("user1@example.com", await user1.getAddress()))
        .to.emit(nftStorageAndTransfer, "EmailLinked")
        .withArgs("user1@example.com", await user1.getAddress());
    });
  });

  describe("NFT Storing", function () {
    it("should allow storing an NFT for an email", async function () {
      await mockNFT.connect(deployer).mint(await deployer.getAddress(), 1);
      await mockNFT.connect(deployer).approve(nftStorageAndTransfer.address, 1);

      await expect(nftStorageAndTransfer.connect(deployer).storeNFT(mockNFT.address, 1, "user1@example.com"))
        .to.emit(nftStorageAndTransfer, "NFTStored")
        .withArgs(mockNFT.address, 1, "user1@example.com");
    });
  });

  describe("NFT Claiming", function () {
    beforeEach(async function () {
        await mockNFT.connect(deployer).mint(await deployer.getAddress(), 1);
        await mockNFT.connect(deployer).approve(nftStorageAndTransfer.address, 1);
        await nftStorageAndTransfer.connect(deployer).storeNFT(mockNFT.address, 1, "user1@example.com");
        await nftStorageAndTransfer.connect(deployer).linkEmailToAddress("user1@example.com", await user1.getAddress());
    });

    it("should allow claiming a stored NFT with a linked email", async function () {
        await expect(nftStorageAndTransfer.connect(user1).claimStoredNFT(mockNFT.address, 1, "user1@example.com"))
            .to.emit(nftStorageAndTransfer, "NFTTransferred")
            .withArgs(mockNFT.address, nftStorageAndTransfer.address, await user1.getAddress(), 1);
    });
});

  describe("Direct NFT Transfer", function () {
    it("should allow direct transfer of an NFT to a linked email", async function () {
      await mockNFT.connect(deployer).mint(await deployer.getAddress(), 1);
      await mockNFT.connect(deployer).approve(nftStorageAndTransfer.address, 1);
      await nftStorageAndTransfer.connect(deployer).linkEmailToAddress("user1@example.com", await user1.getAddress());

      await expect(nftStorageAndTransfer.connect(deployer).transferNFT(mockNFT.address, "user1@example.com", 1))
        .to.emit(nftStorageAndTransfer, "NFTTransferred")
        .withArgs(mockNFT.address, await deployer.getAddress(), await user1.getAddress(), 1);
    });
  });
});
