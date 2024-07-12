import { ethers } from "hardhat";
import { Buffer } from "buffer";

async function main() {
    const signers = await ethers.getSigners();
    if (signers.length < 2) {
        console.error("Not enough signers available. Make sure you have at least two accounts.");
        process.exit(1);
    }
    const deployer = signers[0];
    const user1 = signers[1];

    console.log("Interacting with contracts using the account:", deployer.address);
    console.log("User1 account:", user1.address);

    const nftCustodyAddress = "0xdC26577F40AC6eeBd2E5c2Fc7DB941b006Fbec07"; // Update this with your actual NFTCustody contract address
    const NFTCustody = await ethers.getContractAt("NFTCustody", nftCustodyAddress);

    console.log("NFTCustody contract fetched at address:", NFTCustody.address);

    try {
        // Grant MINTER_ROLE with manual gas limit
        const MINTER_ROLE = await NFTCustody.MINTER_ROLE();
        console.log("MINTER_ROLE:", MINTER_ROLE);

        await NFTCustody.connect(deployer).grantRole(MINTER_ROLE, deployer.address, { gasLimit: 500000 });
        console.log("Granted MINTER_ROLE to deployer");

        await NFTCustody.connect(deployer).grantRole(MINTER_ROLE, user1.address, { gasLimit: 500000 });
        console.log("Granted MINTER_ROLE to user1");

        // Ensure the NFT is approved for transfer by the contract
        const nftContract = await ethers.getContractAt("IERC721", nftCustodyAddress);
        await nftContract.connect(user1).approve(NFTCustody.address, 1, { gasLimit: 500000 });
        console.log("NFT approved for transfer");

        // Deposit NFT and set metadata with manual gas limit
        await NFTCustody.connect(user1).depositNFT("user1", 1, nftCustodyAddress, "Forward", "Example Team", 100, "https://example.com/1.png", { gasLimit: 500000 });
        console.log("NFT deposited");

        await NFTCustody.connect(user1).claimNFT("user1", user1.address, { gasLimit: 500000 });
        console.log("NFT claimed");

        const tokenURI = await NFTCustody.tokenURI(1);
        console.log("Token URI: ", tokenURI);

        // Decode base64
        const base64Data = tokenURI.split(",")[1];
        const jsonMetadata = Buffer.from(base64Data, 'base64').toString('utf8');
        console.log("Decoded JSON Metadata: ", jsonMetadata);
    } catch (error) {
        console.error("Error during interaction:", error);
    }
}

main().catch((error) => {
    console.error("Error in main execution:", error);
    process.exit(1);
});
