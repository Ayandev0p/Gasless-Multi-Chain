// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./UserOp.sol";

interface IPaymaster {
    /**
     * @dev Validate request and optionally sponsor gas.
     * Should return context used by postOp, and validationData (0 for success).
     */
    function validatePaymasterUserOp(
        UserOpLib.UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) external returns (bytes memory context, uint256 validationData);

    function postOp(uint8 mode, bytes calldata context, uint256 actualGasCost) external;
}
