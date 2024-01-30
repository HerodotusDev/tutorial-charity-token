// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "../src/Charity.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new Charity();

        vm.stopBroadcast();
    }
}
