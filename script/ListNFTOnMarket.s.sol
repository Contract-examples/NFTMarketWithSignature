// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/NFTMarket.sol";
import "../src/MyNFT.sol";

contract ListNFTOnMarketScript is Script {
    function run() external {
        //TODO encrypt private key
        uint256 privateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        address seller = vm.addr(privateKey);

        // replace your nft market contract address
        address marketAddress = 0xEaBDC6F5FC592520163729bDFAe1bD891DbE9b4F;
        NFTMarket market = NFTMarket(marketAddress);

        // replace your nft contract address
        address nftAddress = 0x0C9411984a111B26F2518e70D3731779103c9c35;
        MyNFT nft = MyNFT(nftAddress);

        // sell tokenId 0
        uint256 tokenId = 0;

        // price is 100 $MTK
        uint256 price = 100 * 10 ** 18;

        vm.startBroadcast(privateKey);

        // let market contract approve nft
        nft.approve(marketAddress, tokenId);

        // list nft on market
        market.list(tokenId, price);

        vm.stopBroadcast();

        console2.log("NFT listed on market:");
        console2.log("Seller:", seller);
        console2.log("Token ID:", tokenId);
        console2.log("Price:", price);
        console2.log("Market address:", marketAddress);
    }
}
