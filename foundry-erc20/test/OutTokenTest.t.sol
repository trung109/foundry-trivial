// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        // Transfer initial balance to Bob
        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public view {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        // Bob approves Alice to spend his tokens
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Alice transfers tokens from Bob to herself
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(transferAmount, ourToken.balanceOf(alice));
        assertEq(STARTING_BALANCE - transferAmount, ourToken.balanceOf(bob));
    }

    function testTransfer() public {
        uint256 transferAmount = 50;

        // Bob transfers tokens to Alice
        vm.prank(bob);
        ourToken.transfer(alice, transferAmount);

        assertEq(transferAmount, ourToken.balanceOf(alice));
        assertEq(STARTING_BALANCE - transferAmount, ourToken.balanceOf(bob));
    }

    function testBurn() public {
        uint256 burnAmount = 20;

        // Bob burns some of his tokens
        vm.prank(bob);
        ourToken.burn(burnAmount);

        assertEq(STARTING_BALANCE - burnAmount, ourToken.balanceOf(bob));
        assertEq(INITIAL_SUPPLY - burnAmount, ourToken.totalSupply());
    }

    function testMint() public {
        uint256 mintAmount = 100;

        // Mint new tokens to Bob
        vm.prank(msg.sender); // Assuming only the deployer can mint
        ourToken.mint(bob, mintAmount);

        assertEq(STARTING_BALANCE + mintAmount, ourToken.balanceOf(bob));
        assertEq(INITIAL_SUPPLY + mintAmount, ourToken.totalSupply());
    }

    function testTotalSupply() public view {
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testTransferExceedingBalance() public {
        uint256 exceedingAmount = STARTING_BALANCE + 1;

        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC20InsufficientBalance.selector,
                address(bob),
                STARTING_BALANCE,
                exceedingAmount
            )
        );
        ourToken.transfer(alice, exceedingAmount);
    }

    function testApproveExceedingAllowance() public {
        uint256 exceedingAmount = 2000;

        vm.prank(bob);
        ourToken.approve(alice, exceedingAmount);

        assertEq(ourToken.allowance(bob, alice), exceedingAmount);
    }
}
