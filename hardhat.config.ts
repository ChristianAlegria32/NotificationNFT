import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "hardhat-docgen";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    polygonAmoy: {
      url: process.env.POLYGONAMOY_URL || "",
      accounts: process.env.PRIVATE_KEY && process.env.PRIVATE_KEY2 ? [process.env.PRIVATE_KEY, process.env.PRIVATE_KEY2] : [],
    },
  },
  etherscan:{
    apiKey: process.env.ETHERSCAN_KEY,
  },
  docgen: {
    path: './docs',
    clear: true,
    runOnCompile: false,
  },
};

export default config;
