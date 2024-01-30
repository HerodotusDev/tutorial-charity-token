// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/Charity.sol";

contract CharityTest is Test {
    Charity public charity;
    address payable donor;
    address payable owner;

    function setUp() public {
        // Retrieve the deployer's private key from an environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // Derive the deployer's address from the private key
        address deployerAddress = vm.addr(deployerPrivateKey);

        // Simulate contract deployment by the deployer account
        vm.startPrank(deployerAddress);
        charity = new Charity();
        vm.stopPrank();

        // Set the mock donor address and owner address
        donor = payable(address(1)); // Mock donor address
        owner = payable(deployerAddress); // Owner is the deployer
    }

    function testInitialDonation() public {
        // Fund the donor address with 1 ether
        vm.deal(donor, 1 ether);
        // Simulate a donation from the donor
        vm.prank(donor);
        charity.donate{value: 1 ether}();

        // Check if the donation is recorded correctly
        uint256 recordedAmount = charity.benefactors(donor);
        assertEq(
            recordedAmount,
            1 ether,
            "Donation should be recorded correctly"
        );
    }

    function testSubsequentDonation() public {
        // Ensure the donor has enough funds
        vm.deal(donor, 2 ether);
        // Start simulating transactions from the donor
        vm.startPrank(donor);

        charity.donate{value: 1 ether}();
        charity.donate{value: 1 ether}();

        // Stop simulating transactions from the donor
        vm.stopPrank();

        // Check if the total donations are accumulated correctly
        uint256 recordedAmount = charity.benefactors(donor);
        assertEq(
            recordedAmount,
            2 ether,
            "Total donations should accumulate correctly"
        );
    }

    function testWithdraw() public {
        // Ensure the donor has donated 2 ether
        vm.deal(donor, 2 ether);
        vm.prank(donor);
        charity.donate{value: 2 ether}();

        // Check the initial balance of the owner
        uint256 initialBalance = address(owner).balance;

        // Simulate the withdrawal by the owner
        vm.prank(owner);
        charity.withdraw_all();

        // Check the final balance of the owner
        uint256 finalBalance = address(owner).balance;
        assertEq(
            finalBalance,
            initialBalance + 2 ether,
            "Withdraw should transfer the correct amount"
        );
    }
}
