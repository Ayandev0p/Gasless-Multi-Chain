// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleClaimTarget is Ownable {
    IERC20 public immutable token;
    mapping(address => uint256) public allowance;
    mapping(address => uint256) public claimed;

    event Claimed(address indexed user, uint256 amount);

    constructor(IERC20 _token) { token = _token; }

    function setAllowance(address user, uint256 alloc) external onlyOwner { allowance[user] = alloc; }

    function claim(uint256 amount) external {
        require(allowance[msg.sender] >= claimed[msg.sender] + amount, "exceeds");
        claimed[msg.sender] += amount;
        require(token.transfer(msg.sender, amount), "transfer failed");
        emit Claimed(msg.sender, amount);
    }
}
