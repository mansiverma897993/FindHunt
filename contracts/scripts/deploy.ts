import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

async function main() {
  const signers = await ethers.getSigners();
  const deployer = signers[0];
  if (!deployer) {
    console.error(
      "\n[FindHunt] No deployer account. Set DEPLOYER_PRIVATE_KEY in .env.local (repo root) with 0x… and fund the wallet on Hela Testnet.\n"
    );
    process.exit(1);
  }
  console.log("Deployer:", deployer.address);

  const TreasurerVault = await ethers.getContractFactory("TreasurerVault");
  const vault = await TreasurerVault.deploy();
  await vault.waitForDeployment();
  const vaultAddr = await vault.getAddress();
  console.log("TreasurerVault:", vaultAddr);

  const StrategyExecutor = await ethers.getContractFactory("StrategyExecutor");
  const executor = await StrategyExecutor.deploy(vaultAddr);
  await executor.waitForDeployment();
  const execAddr = await executor.getAddress();
  console.log("StrategyExecutor:", execAddr);

  await (await vault.setStrategyExecutor(execAddr)).wait();
  console.log("Vault strategy executor set");

  const BudgetController = await ethers.getContractFactory("BudgetController");
  const budget = await BudgetController.deploy();
  await budget.waitForDeployment();
  const budgetAddr = await budget.getAddress();
  console.log("BudgetController:", budgetAddr);

  const SubscriptionManager = await ethers.getContractFactory("SubscriptionManager");
  const subs = await SubscriptionManager.deploy();
  await subs.waitForDeployment();
  const subsAddr = await subs.getAddress();
  console.log("SubscriptionManager:", subsAddr);

  const MockLPPool = await ethers.getContractFactory("MockLPPool");
  const lp = await MockLPPool.deploy("HL-USDC Mock LP");
  await lp.waitForDeployment();
  const lpAddr = await lp.getAddress();
  console.log("MockLPPool:", lpAddr);

  const out = {
    network: "helaTestnet",
    chainId: 666888,
    deployer: deployer.address,
    TreasurerVault: vaultAddr,
    StrategyExecutor: execAddr,
    BudgetController: budgetAddr,
    SubscriptionManager: subsAddr,
    MockLPPool: lpAddr,
  };

  const root = path.join(__dirname, "..", "..");
  const envPath = path.join(root, "deployed-addresses.json");
  fs.writeFileSync(envPath, JSON.stringify(out, null, 2));
  console.log("Wrote", envPath);

  const explorer = "https://testnet-blockexplorer.helachain.com";
  const lines = [
    `# FindHunt — paste into .env.local (project root)`,
    `NEXT_PUBLIC_TREASURER_VAULT=${vaultAddr}`,
    `NEXT_PUBLIC_STRATEGY_EXECUTOR=${execAddr}`,
    `NEXT_PUBLIC_BUDGET_CONTROLLER=${budgetAddr}`,
    `NEXT_PUBLIC_SUBSCRIPTION_MANAGER=${subsAddr}`,
    `NEXT_PUBLIC_MOCK_LP_POOL=${lpAddr}`,
    ``,
    `# Hela Testnet`,
    `NEXT_PUBLIC_HELA_RPC_URL=${process.env.HELA_TESTNET_RPC_URL || "https://testnet-rpc.helachain.com"}`,
  ];
  const envSnippet = path.join(root, "hela-contracts.env");
  fs.writeFileSync(envSnippet, lines.join("\n"));
  console.log("Wrote", envSnippet);

  console.log("\n=== Hela Testnet — block explorer links ===\n");
  const links: [string, string][] = [
    ["TreasurerVault", vaultAddr],
    ["StrategyExecutor", execAddr],
    ["BudgetController", budgetAddr],
    ["SubscriptionManager", subsAddr],
    ["MockLPPool", lpAddr],
  ];
  for (const [name, addr] of links) {
    console.log(`${name}: ${explorer}/address/${addr}`);
  }
  console.log("\nRestart Next.js after updating .env.local so the app picks up contract addresses.\n");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
