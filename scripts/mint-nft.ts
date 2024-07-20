import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Minting an NFT with the account:", deployer.address);

  // Check deployer's balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.utils.formatEther(balance));

  const minBalance = ethers.utils.parseEther("0.01");
  
  if (balance.lt(minBalance)) {
    throw new Error("Not enough ETH to pay for gas fees");
  }

  const contractAddress = process.env.NFT_CONTRACT_ADDRESS || "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const SimpleNFT = await ethers.getContractFactory("SimpleNFT");
  const simpleNFT = await SimpleNFT.attach(contractAddress);

  const tokenURI = "https://ipfs.io/ipfs/QmTxhzfg74BhEJgJ4yQmvSEgYo5ZrjBwyk2nCX1N1GnRYp";
  
  try {
    const tx = await simpleNFT.mint(tokenURI);
    await tx.wait();
    console.log("NFT minted successfully with token URI:", tokenURI);
    
    // Get the latest token ID
    const tokenId = await simpleNFT.tokenCounter();
    console.log("Minted token ID:", tokenId.toString());
  } catch (error) {
    console.error("Error minting NFT:", error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error details:");
    console.error(error);
    process.exit(1);
  });