// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/Charity.sol";

contract CharityTest is Test {
    Charity public charity;
    address payable donor;
    address payable owner;
    uint256 starknetAddress;

    function setUp() public {
        // Retrieve the deployer's private key from an environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // Derive the deployer's address from the private key
        address deployerAddress = vm.addr(deployerPrivateKey);

        starknetAddress = 0x0278619D391034A091b099C6Fd53A3Dc56859196f9aC67bE75B3AD3Bff4869f6;

        // Simulate contract deployment by the deployer account
        vm.startPrank(deployerAddress);
        charity = new Charity();
        vm.stopPrank();

        // Set the mock donor address and owner address
        donor = payable(address(1)); // Mock donor address
        owner = payable(deployerAddress); // Owner is the deployer
    }

    function testWithdraw() public {
        // Ensure the donor has donated 2 ether
        vm.deal(donor, 2 ether);
        vm.prank(donor);
        charity.donate{value: 2 ether}(starknetAddress);

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
