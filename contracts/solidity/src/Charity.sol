// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

contract Charity {
    struct DonationInfo {
        uint256 starknetAddress;
        uint256 amount;
    }

    event Donation(address benefactor, uint256 amount, uint256 starknetAddress);

    mapping(address => DonationInfo) public benefactors;
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function donate(uint256 starknetAddress) external payable {
        require(msg.value > 0, "Pls gib more money :c");

        // Record or accumulate the donation amount for the sender
        benefactors[msg.sender].amount += msg.value;
        benefactors[msg.sender].starknetAddress = starknetAddress;

        // Emit the Donation event
        emit Donation(msg.sender, msg.value, starknetAddress);
    }

    function withdraw_all() external {
        require(msg.sender == _owner, "No takesies backsies :)");

        // Withdraw the entire balance of the contract
        payable(_owner).transfer(address(this).balance);
    }
}
