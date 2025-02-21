// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    address USER = makeAddr("user");

    uint256 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 5e18}();
        _;
    }

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10e18);
    }

    function testMinimumUsd() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWIthoutEnoughETH() public {
        vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
        fundMe.fund(); // <- We send 0 value
    }

    function testFund() public funded {
        assertEq(fundMe.getAddressToAmountFunded(USER), 5e18);
    }

    function testAddFunderToFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawSingleFunder() public funded {
        // Arrange
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endFunderBalance = address(fundMe).balance;
        assertEq(endFunderBalance, 0);
        assertEq(startOwnerBalance + startFundMeBalance, endOwnerBalance);
    }

    function testWithdrawMultipleFunders() public funded {
        // Arrange
        uint256 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), 5e18);
            fundMe.fund{value: 5e18}();
        }
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startFundMeBalance + startOwnerBalance, fundMe.getOwner().balance);
    }

    function testWithdrawMultipleFundersCheaper() public funded {
        // Arrange
        uint256 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), 5e18);
            fundMe.fund{value: 5e18}();
        }
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(startFundMeBalance + startOwnerBalance, fundMe.getOwner().balance);
    }
}
