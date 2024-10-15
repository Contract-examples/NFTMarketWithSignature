// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/MyERC20Token.sol";

contract DeployMyERC20TokenScript is Script {
    function setUp() public { }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // deploy MyERC20Token
        MyERC20Token token = new MyERC20Token();
        console2.log("MyERC20Token deployed to:", address(token));

        console2.log("Deployed by:", deployerAddress);

        vm.stopBroadcast();
    }
}
