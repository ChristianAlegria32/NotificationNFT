import { ethers } from "hardhat";

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

    const nftCustodyAddress = "0x752E8eE79eeD386d746BfaE53E201556bE0b0a17"; // Use your actual NFTCustody contract address
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

        // Mint an NFT and set metadata with manual gas limit
        await NFTCustody.connect(user1).depositNFT("user1", 1, NFTCustody.address, { gasLimit: 500000 });
        console.log("NFT deposited");

        await NFTCustody.connect(user1).claimNFT("user1", user1.address, "Forward", "Example Team", 100, "https://example.com/1.png", { gasLimit: 500000 });
        console.log("NFT claimed");

        const tokenURI = await NFTCustody.tokenURI(1);
        console.log("Token URI: ", tokenURI);
    } catch (error) {
        console.error("Error during interaction:", error);
    }
}

main().catch((error) => {
    console.error("Error in main execution:", error);
    process.exit(1);
});
