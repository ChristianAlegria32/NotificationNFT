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

    const nftCustodyAddress = "0x7a44AA14BD35aec7691A5b2cAAf83ab3dc1Fa195"; // Update this with your actual NFTCustody contract address

    try {
        const contractCode = await ethers.provider.getCode(nftCustodyAddress);
        if (contractCode === "0x") {
            console.error("No contract deployed at the specified address.");
            return;
        }
        console.log(`Contract code at address ${nftCustodyAddress}:`, contractCode);

        const NFTCustody = await ethers.getContractAt("NFTCustody", nftCustodyAddress);
        console.log("NFTCustody contract fetched at address:", nftCustodyAddress);

        const MINTER_ROLE = await NFTCustody.MINTER_ROLE();
        console.log("MINTER_ROLE:", MINTER_ROLE);

        const grantRoleTx1 = await NFTCustody.connect(deployer).grantRole(MINTER_ROLE, deployer.address, { gasLimit: 500000 });
        await grantRoleTx1.wait();
        console.log("Granted MINTER_ROLE to deployer");

        const grantRoleTx2 = await NFTCustody.connect(deployer).grantRole(MINTER_ROLE, user1.address, { gasLimit: 500000 });
        await grantRoleTx2.wait();
        console.log("Granted MINTER_ROLE to user1");

        const nftContract = await ethers.getContractAt("IERC721", nftCustodyAddress);
        const approveTx = await nftContract.connect(user1).approve(NFTCustody.address, 1, { gasLimit: 500000 });
        await approveTx.wait();
        console.log("NFT approved for transfer");

        const depositTx = await NFTCustody.connect(user1).depositNFT("user1", 1, nftCustodyAddress, "Forward", "Example Team", 100, "https://example.com/1.png", { gasLimit: 500000 });
        await depositTx.wait();
        console.log("NFT deposited");

        const claimTx = await NFTCustody.connect(user1).claimNFT("user1", user1.address, { gasLimit: 500000 });
        await claimTx.wait();
        console.log("NFT claimed");

        const tokenURI = await NFTCustody.tokenURI(1);
        console.log("Token URI: ", tokenURI);

        const base64Data = tokenURI.split(",")[1];
        const jsonMetadata = Buffer.from(base64Data, 'base64').toString('utf8');
        console.log("Decoded JSON Metadata: ", jsonMetadata);
    } catch (error: any) {
        console.error("Error during interaction:", error.reason || error.message);
    }
}

main().catch((error) => {
    console.error("Error in main execution:", error.reason || error.message);
    process.exit(1);
});
