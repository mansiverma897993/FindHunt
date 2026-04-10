import { expect } from "chai";
import { ethers } from "hardhat";

describe("TreasurerVault", function () {
  it("deposits and withdraws", async function () {
    const [a] = await ethers.getSigners();
    const V = await ethers.getContractFactory("TreasurerVault");
    const v = await V.deploy();
    await v.waitForDeployment();
    await v.connect(a).deposit({ value: ethers.parseEther("1") });
    expect(await v.balances(a.address)).to.equal(ethers.parseEther("1"));
    await v.connect(a).withdraw(ethers.parseEther("0.5"));
    expect(await v.balances(a.address)).to.equal(ethers.parseEther("0.5"));
  });
});
