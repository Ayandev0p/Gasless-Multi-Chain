import { expect } from "chai";
import { ethers } from "hardhat";

describe("MinimalVerifyingPaymaster (demo)", () => {
  it("deploys and verifies demo signature", async () => {
    const [signer] = await ethers.getSigners();
    const EP = "0x0000000000000000000000000000000000000000";
    const Pay = await ethers.getContractFactory("MinimalVerifyingPaymaster");
    const pay = await Pay.deploy(EP as any, await signer.getAddress());
    await pay.waitForDeployment();

    const userOpHash = ethers.keccak256(ethers.toUtf8Bytes("demo"));
    const validUntil = 0;
    const validAfter = 0;
    const digest = ethers.keccak256(ethers.AbiCoder.defaultAbiCoder().encode(
      ["bytes32","uint48","uint48","address"], [userOpHash, validUntil, validAfter, await pay.getAddress()]
    ));
    const sig = await signer.signMessage(ethers.getBytes(digest));
    expect(await pay.verifyForDemo(userOpHash, validUntil, validAfter, sig)).to.eq(true);
  });
});
