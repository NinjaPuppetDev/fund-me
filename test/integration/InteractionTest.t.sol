// SPDX-License-Identfier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionTest is Test {
    FundMe public fundMe;

    address USER = address(1);

    uint256 constant SEND_VALUE = 10 ether;
    uint256 constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;
    address i_owner;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();

        i_owner = fundMe.getOwner();
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanFundInteractions() public {
        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}();

        console.log("FundMe contract balance: %s", address(fundMe).balance);

        assertEq(address(fundMe).balance, SEND_VALUE);

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testUserCanWithdraw() public {
        vm.prank(USER); // Use a random non-owner address to fund
        fundMe.fund{value: SEND_VALUE}();
        address owner = fundMe.getOwner();
        vm.prank(owner);
        fundMe.withdraw();
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
