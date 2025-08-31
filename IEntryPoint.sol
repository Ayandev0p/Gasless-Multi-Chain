// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./UserOp.sol";

interface IEntryPoint {
    // Minimal interface for deposit and event visibility
    function depositTo(address account) external payable;
    function balanceOf(address account) external view returns (uint256);
}
