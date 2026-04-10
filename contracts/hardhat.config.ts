import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
import * as path from "path";

const rootEnv = path.resolve(__dirname, "..", ".env");
const rootEnvLocal = path.resolve(__dirname, "..", ".env.local");
dotenv.config({ path: rootEnv });
dotenv.config({ path: rootEnvLocal });

const helaRpc = process.env.HELA_TESTNET_RPC_URL || "https://testnet-rpc.helachain.com";
const deployKey = process.env.DEPLOYER_PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: { optimizer: { enabled: true, runs: 200 } },
  },
  networks: {
    hardhat: {},
    helaTestnet: {
      url: helaRpc,
      chainId: 666888,
      accounts: deployKey ? [deployKey] : [],
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
};

export default config;
