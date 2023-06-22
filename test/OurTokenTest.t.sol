// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {OurToken} from "src/OurToken.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {Test, console} from "forge-std/Test.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    uint256 public STARTING_BALANCE = 100 ether;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() external {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assert(ourToken.balanceOf(bob) == STARTING_BALANCE);
    }

    function testAllowance() public {
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        assertEq(ourToken.allowance(bob, alice), initialAllowance);
    }

    function testTransfer() public {
        uint256 transferAmount = 50;

        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(alice), transferAmount);
    }

    function testTransferFrom() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(
            ourToken.allowance(bob, alice),
            initialAllowance - transferAmount
        );
    }

    function testInsufficientAllowance() public {
        uint256 initialAllowance = 100;
        uint256 transferAmount = 200;

        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        vm.prank(alice);
        vm.expectRevert();
        bool transferResult = ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), 0);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
        assertEq(ourToken.allowance(bob, alice), initialAllowance);
        assertEq(transferResult, false);
    }

    function testTransferToContract() public {
        uint256 transferAmount = 50;
        DeployOurToken contractReceiver = new DeployOurToken();

        vm.prank(bob);
        ourToken.transfer(address(contractReceiver), transferAmount);

        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(address(contractReceiver)), transferAmount);
    }
}
