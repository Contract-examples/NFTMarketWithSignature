// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "../src/MyNFT.sol";

contract MintMyNFT is Script {
    function run() external {
        //TODO encrypt private key
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        // replace with your nft contract address
        address nftAddress = 0x32eCC13478b2d03b212AE7b371F5f3C18490Bc9d;
        MyNFT nft = MyNFT(nftAddress);

        // replace with your metadata URI
        // https://ipfs.io/ipfs/QmNv6Br4XyKsPLTexFYSv9dvGkRnxqqkJgxcLTW9rb94e6 (gmh)
        // https://ipfs.io/ipfs/QmZFCuv8NKTAhaNTXx9X6iXnUkgdpbNJAhBHvEUZHzJnmf (newworld)
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
