// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/MyERC20PermitToken.sol";

contract DeployMyERC20PermitTokenScript is Script {
    function setUp() public { }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // deploy MyERC20PermitToken
        MyERC20PermitToken token = new MyERC20PermitToken("MyNFTToken2612", "MTK2612", 1_000_000 * 10 ** 18);
        console2.log("MyERC20PermitToken deployed to:", address(token));

        console2.log("Deployed by:", deployerAddress);

        vm.stopBroadcast();
    }
}
