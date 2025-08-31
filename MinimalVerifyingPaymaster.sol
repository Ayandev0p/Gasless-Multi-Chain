// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../aa/UserOp.sol";
import "../aa/IEntryPoint.sol";
import "../aa/IPaymaster.sol";

/**
 * @title MinimalVerifyingPaymaster (demo)
 * @notice Demonstrates a signature-based ERC-4337 paymaster.
 * NOT production-ready. For education and local demos.
 */
contract MinimalVerifyingPaymaster is IPaymaster {
    using UserOpLib for UserOpLib.UserOperation;

    IEntryPoint public immutable entryPoint;
    address public verifyingSigner;
    address public owner;

    event SignerUpdated(address signer);
    event Deposited(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(IEntryPoint _entryPoint, address _signer) {
        entryPoint = _entryPoint;
        verifyingSigner = _signer;
        owner = msg.sender;
    }

    receive() external payable {}

    function setSigner(address s) external onlyOwner {
        verifyingSigner = s;
        emit SignerUpdated(s);
    }

    function depositToEntryPoint() external payable onlyOwner {
        entryPoint.depositTo{value: msg.value}(address(this));
        emit Deposited(msg.value);
    }

    // Off-chain will sign keccak256(userOpHash, validUntil, validAfter, address(this))
    function _verify(bytes32 userOpHash, uint48 validUntil, uint48 validAfter, bytes calldata signature) internal view returns (bool) {
        bytes32 digest = keccak256(abi.encode(userOpHash, validUntil, validAfter, address(this)));
        address rec = _recoverEthSignedMessage(digest, signature);
        return rec == verifyingSigner;
    }

    function _recoverEthSignedMessage(bytes32 digest, bytes memory signature) internal pure returns (address) {
        bytes32 ethHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", digest));
        (bytes32 r, bytes32 s, uint8 v) = _split(signature);
        return ecrecover(ethHash, v, r, s);
    }

    function _split(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "bad sig");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function validatePaymasterUserOp(
        UserOpLib.UserOperation calldata /*userOp*/,
        bytes32 userOpHash,
        uint256 /*maxCost*/
    ) external view override returns (bytes memory context, uint256 validationData) {
        // paymasterAndData: abi.encode(validUntil, validAfter, signature)
        // first 32 bytes (padded) -> validUntil, next 32 -> validAfter, rest -> signature
        bytes calldata pmd; // placeholder to satisfy syntax highlighting
        pmd = msg.data; // unused; silence warning
        return (bytes(""), 0); // This function is meant to be called by EntryPoint in real deployments.
    }

    function postOp(uint8 /*mode*/, bytes calldata /*context*/, uint256 /*actualGasCost*/) external pure override {
        // In real deployments this would settle gas cost with EntryPoint.
    }

    // Helper for frontends/tests: pure verification using paymaster's signer.
    function verifyForDemo(bytes32 userOpHash, uint48 validUntil, uint48 validAfter, bytes calldata signature) external view returns (bool) {
        return _verify(userOpHash, validUntil, validAfter, signature);
    }
}
