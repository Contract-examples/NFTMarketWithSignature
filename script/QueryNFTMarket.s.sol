// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/NFTMarket.sol";
import "../src/MyNFT.sol";

contract QueryNFTMarketScript is Script {
    function run() external view {
        // replace your nft market contract address
        address marketAddress = 0xEaBDC6F5FC592520163729bDFAe1bD891DbE9b4F;
        NFTMarket market = NFTMarket(marketAddress);

        // replace your nft contract address
        address nftAddress = 0x0C9411984a111B26F2518e70D3731779103c9c35;
        MyNFT nft = MyNFT(nftAddress);

        uint256 totalSupply = nft.totalSupply();

        console2.log("NFTs listed on the market:");
        console2.log("----------------------------");

        for (uint256 i = 0; i < totalSupply; i++) {
            (address seller, uint256 price) = market.listings(i);
            if (seller != address(0)) {
                address owner = nft.ownerOf(i);
                console2.log("Token ID:", i);
                console2.log("Price:", price);
                console2.log("Seller:", seller);
                console2.log("Current Owner:", owner);
                console2.log("----------------------------");
            }
        }
    }
}
