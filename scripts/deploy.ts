import { ethers } from "hardhat";

async function main() {
    const NFTStorageAndTransferFactory = await ethers.getContractFactory("NFTStorageAndTransfer");
    const nftStorageAndTransfer = await NFTStorageAndTransferFactory.deploy();
    await nftStorageAndTransfer.deployed();

    console.log(`NFTStorageAndTransfer deployed to: ${nftStorageAndTransfer.address}`);
}
main().catch((error) => {
    console.error(error);
    process.exit(1);
});
