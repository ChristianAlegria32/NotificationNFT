import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "hardhat-docgen";
import * as tenderly from "@tenderly/hardhat-tenderly";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    polygonAmoy: {
      url: process.env.POLYGONAMOY_URL || "",
      accounts: process.env.PRIVATE_KEY && process.env.PRIVATE_KEY2 ? [process.env.PRIVATE_KEY, process.env.PRIVATE_KEY2] : [],
    },
    virtual_polygon: {
      url: "https://virtual.polygon.rpc.tenderly.co/861de523-16fa-40aa-aae2-59171f113ba0",
      chainId: 137,
    },
  },
  etherscan:{
    apiKey: process.env.ETHERSCAN_KEY,
  },
  tenderly: {
    // https://docs.tenderly.co/account/projects/account-project-slug
    project: "custodynft",
    username: "ChrisAlegria",
  },
  docgen: {
    path: './docs',
    clear: true,
    runOnCompile: false,
  },
};

export default config;
