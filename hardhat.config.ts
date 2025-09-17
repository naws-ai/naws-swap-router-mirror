import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {version: "0.8.7"},
      // { version: "0.7.6" },
    ],
  },
  networks: {
    mainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      // accounts: { mnemonic: process.env.METAMASK_MNEMONIC },
      accounts: [process.env.DEPLOY_PRIVATE_KEY as string],
      gasPrice: 1_000_000_000,
    },
    // goerli: {
    //   url: process.env.GOERLI_URL,
    //   accounts: [process.env.GOERLI_ACCOUNT as string]
    // }
  },
  etherscan: {
    apiKey: {
      bsc: process.env.BSC_API_KEY as string,
    },
  },
};

export default config;
