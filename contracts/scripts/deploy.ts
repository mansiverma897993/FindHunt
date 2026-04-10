import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";

async function main() {
  const [deployer] = await ethers.getSigners();
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
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
