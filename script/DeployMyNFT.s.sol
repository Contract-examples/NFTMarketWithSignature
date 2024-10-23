// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/MyNFT.sol";

contract DeployMyNFT is Script {
    function run() external {
        //TODO encrypt private key
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        MyNFT nft = new MyNFT("MyNFT", "MFT", 1000);

        vm.stopBroadcast();

        console2.log("MyNFT deployed to:", address(nft));
        console2.log("Contract name:", nft.name());
        console2.log("Contract symbol:", nft.symbol());
        console2.log("Max supply:", nft.MaxSupply());
        console2.log("Initial user mint supply:", nft.MintSupplyForUsers());
    }
}
