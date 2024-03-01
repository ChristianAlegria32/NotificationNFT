import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, Signer } from "ethers";

describe("NFTCustody", function () {
  let mockNFT: Contract;
  let nftCustody: Contract;
  let owner: Signer, user1: Signer, user2: Signer;

  before(async function () {
    const signers = await ethers.getSigners();
    owner = signers[0];
    user1 = signers[1];
    user2 = signers[2];
  });

  beforeEach(async function () {
    const MockNFT = await ethers.getContractFactory("MockNFT");
    mockNFT = await MockNFT.deploy();
  
    // Mint NFT to user1
    await mockNFT.connect(owner).mint(await user1.getAddress(), 1);
  
    const NFTCustody = await ethers.getContractFactory("NFTCustody");
    nftCustody = await NFTCustody.deploy();
  });
  
  describe("Deposit and Claim NFTs", function () {
    it("Should deposit an NFT and allow the user to claim it", async function () {
      await (mockNFT.connect(user1) as any).approve(nftCustody.address, 1);

      await (nftCustody.connect(user1) as any).depositNFT("user1", 1, mockNFT.address);

      await expect((nftCustody.connect(user1) as any).claimNFT("user1", await user1.getAddress()))
        .to.emit(nftCustody, "NFTClaimed")
        .withArgs("user1", 1, mockNFT.address, await user1.getAddress());

      expect(await mockNFT.ownerOf(1)).to.equal(await user1.getAddress());
    });

    it("Should not allow claiming NFTs with no deposits", async function () {
      await expect((nftCustody.connect(user2) as any).claimNFT("user2", await user2.getAddress()))
        .to.be.revertedWith("User has no NFTs to claim");
    });
  });
});
 
