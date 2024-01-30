// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

contract Charity {
    event Donation(address benefactor, uint256 amount);

    mapping(address => uint256) public benefactors;
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function donate() external payable {
        require(msg.value > 0, "Pls gib more money...");

        // Record or accumulate the donation amount for the sender
        benefactors[msg.sender] += msg.value;

        // Emit the Donation event
        emit Donation(msg.sender, msg.value);
    }

    function withdraw_all() external {
        require(msg.sender == _owner, "No takesies backsies :)");

        // Withdraw the entire balance of the contract
        payable(_owner).transfer(address(this).balance);
    }
}
