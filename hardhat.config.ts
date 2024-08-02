import "dotenv/config";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-ignition-ethers";
const privateKey = process.env.PRIVATE_KEY!;
//const etherscanApiKey = process.env.ETHERSCAN_API_KEY!

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    testnet: {
      url: "https://base-sepolia-rpc.publicnode.com",
      chainId: 84532,
      accounts: [privateKey],
    },
    mainnet: {
      url: "https://base.llamarpc.com",
      chainId: 8453,
      accounts: [privateKey],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  sourcify: {
    enabled: false,
  },
};

export default config;
