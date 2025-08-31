# Gasless Multi-Chain Token Claimer (ERC-4337 Paymaster) — Demo

This is a **developer-focused demo** that shows how a **signature-based (verifying) paymaster** can sponsor user gas
for token claims. It includes:

- A **MinimalVerifyingPaymaster** contract (4337-style interface, signature-based)
- A simple **claim target** contract and a **mintable ERC20** to fund claims
- Hardhat scripts and tests
- A lightweight Angular frontend stub (connect wallet and show how paymaster verification would be wired)

> NOTE: The paymaster here is a **minimal educational implementation** that compiles and demonstrates signature verification.
> For production, integrate with a real **EntryPoint/Bundler** (e.g., Stackup/Pimlico) and upgrade to a fully compliant paymaster.

## Quick start
```bash
npm i
npx hardhat compile
npx hardhat test
npx hardhat run scripts/deploy.ts
```

## Contracts
- `contracts/paymaster/MinimalVerifyingPaymaster.sol` — verifies an off-chain signer’s approval of a UserOperation hash.
- `contracts/SimpleClaimTarget.sol` — demo target users claim from.
- `contracts/test/ERC20Mint.sol` — helper token for local testing.

## Next steps (to go production)
1. Replace the dummy EntryPoint address with real one and fund via `depositToEntryPoint()`.
2. Generate **user operations** in the frontend and get **paymasterData** from a server that holds the verifying key.
3. Send userOps to a bundler (e.g., Stackup) and monitor receipts.
