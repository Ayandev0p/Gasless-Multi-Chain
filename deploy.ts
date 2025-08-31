import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", await deployer.getAddress());

  const token = await (await ethers.getContractFactory("ERC20Mint")).deploy("DemoToken","DMT");
  await token.waitForDeployment();
  console.log("Token:", await token.getAddress());

  const claim = await (await ethers.getContractFactory("SimpleClaimTarget")).deploy(await token.getAddress());
  await claim.waitForDeployment();
  console.log("ClaimTarget:", await claim.getAddress());

  // fund claim contract
  const mintTx = await token.mint(await claim.getAddress(), 1_000_000e18);
  await mintTx.wait();

  // pseudo EntryPoint and signer (use deployer as signer for demo)
  const entryPoint = "0x0000000000000000000000000000000000000000";
  const paymaster = await (await ethers.getContractFactory("MinimalVerifyingPaymaster")).deploy(entryPoint as any, await deployer.getAddress());
  await paymaster.waitForDeployment();
  console.log("Paymaster:", await paymaster.getAddress());
}

main().catch((e)=>{console.error(e); process.exit(1)});
