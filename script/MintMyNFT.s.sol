// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/MyNFT.sol";

contract MintMyNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        // replace with your nft contract address
        address nftAddress = 0x0C9411984a111B26F2518e70D3731779103c9c35;
        MyNFT nft = MyNFT(nftAddress);

        // replace with your metadata URI
        string memory metadataURI = "https://ipfs.io/ipfs/QmZFCuv8NKTAhaNTXx9X6iXnUkgdpbNJAhBHvEUZHzJnmf";

        vm.startBroadcast(deployerPrivateKey);

        // mint nft with safeMint function
        nft.safeMint(deployerAddress, metadataURI);

        // if you want to use safeMintForUsers function, uncomment the following line and comment out the safeMint line
        // nft.safeMintForUsers(deployerAddress, metadataURI);

        vm.stopBroadcast();

        console.log("NFT minted to:", deployerAddress);
        console.log("Token ID:", nft.MintSupplyForUsers());
        console.log("Metadata URI:", metadataURI);
    }
}
