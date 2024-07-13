import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    try {
        // Deploy NFTCustody
        const NFTCustody = await ethers.getContractFactory("NFTCustody");
        const nftCustody = await NFTCustody.deploy(deployer.address);
        await nftCustody.waitForDeployment(); // Ensure the deployment is confirmed
        const nftCustodyAddress = nftCustody.target; // Get the deployed contract address
        console.log(`NFTCustody deployed to: ${nftCustodyAddress}`);

        // Deploy NFTStorageAndTransfer
        const NFTStorageAndTransfer = await ethers.getContractFactory("NFTStorageAndTransfer");
        const nftStorageAndTransfer = await NFTStorageAndTransfer.deploy();
        await nftStorageAndTransfer.waitForDeployment(); // Ensure the deployment is confirmed
        const nftStorageAndTransferAddress = nftStorageAndTransfer.target; // Get the deployed contract address
        console.log(`NFTStorageAndTransfer deployed to: ${nftStorageAndTransferAddress}`);
    } catch (error) {
        console.error("Error during deployment:", error);
        process.exit(1);
    }
}

main().catch((error) => {
    console.error("Error in main execution:", error);
    process.exit(1);
});
