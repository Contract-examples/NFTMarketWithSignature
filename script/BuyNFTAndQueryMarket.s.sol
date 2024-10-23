// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/NFTMarket.sol";
import "../src/MyNFT.sol";
import "../src/MyERC20PermitToken.sol";

contract BuyNFTAndQueryMarketScript is Script {
    function run() external {
        //TODO encrypt private key
        uint256 buyerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY2");
        address buyer = vm.addr(buyerPrivateKey);

        // replace your nft market contract address
        address marketAddress = 0xEaBDC6F5FC592520163729bDFAe1bD891DbE9b4F;
        // replace your nft contract address
        address nftAddress = 0x0C9411984a111B26F2518e70D3731779103c9c35;
        // replace your payment token contract address
        address tokenAddress = 0x54f0bcb385F758e38eBb3E5085abAb3dB1Cf3153;

        NFTMarket market = NFTMarket(marketAddress);
        MyNFT nft = MyNFT(nftAddress);
        MyERC20PermitToken paymentToken = MyERC20PermitToken(tokenAddress);

        // replace your nft tokenId
        uint256 tokenId = 0;

        vm.startBroadcast(buyerPrivateKey);

        // get nft price
        (address seller, uint256 price) = market.listings(tokenId);
        console2.log("NFT seller:", seller);
        console2.log("NFT price:", price);

        // approve nft market contract use token
        paymentToken.approve(marketAddress, price);

        // buy nft
        market.buyNFT(tokenId);

        vm.stopBroadcast();

        console2.log("NFT purchased:");
        console2.log("Buyer:", buyer);
        console2.log("Token ID:", tokenId);
        console2.log("Price paid:", price);

        // query market status
        queryMarketStatus(market, nft);
    }

    function queryMarketStatus(NFTMarket market, MyNFT nft) internal view {
        uint256 totalSupply = nft.totalSupply();

        console2.log("\nCurrent NFT Market status:");
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
