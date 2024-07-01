import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    // Deploy NFTCustody
    const NFTCustody = await ethers.getContractFactory("NFTCustody");
    const nftCustody = await NFTCustody.deploy(deployer.address);
    await nftCustody.deployed();
    console.log(`NFTCustody deployed to: ${nftCustody.address}`);

    // Deploy NFTStorageAndTransfer
    const NFTStorageAndTransfer = await ethers.getContractFactory("NFTStorageAndTransfer");
    const nftStorageAndTransfer = await NFTStorageAndTransfer.deploy();
    await nftStorageAndTransfer.deployed();
    console.log(`NFTStorageAndTransfer deployed to: ${nftStorageAndTransfer.address}`);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
