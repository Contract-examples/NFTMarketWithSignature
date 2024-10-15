// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/NFTMarket.sol";
import "../src/MyERC20Token.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketTest is Test {
    NFTMarket public market;
    MyERC20Token public paymentToken;
    IERC721 public nftContract;
    address public constant NFT_CONTRACT = 0x0C9411984a111B26F2518e70D3731779103c9c35;

    address public seller;
    address public buyer;
    uint256 public tokenId;

    function setUp() public {
        paymentToken = new MyERC20Token();
        market = new NFTMarket(NFT_CONTRACT, address(paymentToken));
        nftContract = IERC721(NFT_CONTRACT);

        seller = address(0x1);
        buyer = address(0x2);
        tokenId = 1; // token id

        // set up the buyer's balance
        paymentToken.mint(buyer, 1000 * 10 ** 18);

        // set up the seller's NFT
        vm.prank(address(nftContract));
        nftContract.transferFrom(address(nftContract), seller, tokenId);
    }

    function testListNFT() public {
        uint256 price = 100 * 10 ** 18;

        vm.startPrank(seller);
        nftContract.approve(address(market), tokenId);
        market.list(tokenId, price);
        vm.stopPrank();

        (address listedSeller, uint256 listedPrice) = market.listings(tokenId);
        assertEq(listedSeller, seller);
        assertEq(listedPrice, price);
    }

    function testBuyNFT() public {
        uint256 price = 100 * 10 ** 18;

        // list the NFT
        vm.startPrank(seller);
        nftContract.approve(address(market), tokenId);
        market.list(tokenId, price);
        vm.stopPrank();

        // buyer buys the NFT
        vm.startPrank(buyer);
        paymentToken.approve(address(market), price);
        market.buyNFT(tokenId);
        vm.stopPrank();

        assertEq(nftContract.ownerOf(tokenId), buyer);
        assertEq(paymentToken.balanceOf(seller), price);
    }

    function testUnlistNFT() public {
        uint256 price = 100 * 10 ** 18;

        vm.startPrank(seller);
        nftContract.approve(address(market), tokenId);
        market.list(tokenId, price);
        market.unlist(tokenId);
        vm.stopPrank();

        (address listedSeller, uint256 listedPrice) = market.listings(tokenId);
        assertEq(listedSeller, address(0));
        assertEq(listedPrice, 0);
    }

    function testTokensReceivedHook() public {
        uint256 price = 100 * 10 ** 18;

        // list the NFT
        vm.startPrank(seller);
        nftContract.approve(address(market), tokenId);
        market.list(tokenId, price);
        vm.stopPrank();

        // buyer transfers the payment token to the market contract
        vm.startPrank(buyer);
        bytes memory data = abi.encode(tokenId);
        paymentToken.transferAndCall(address(market), price, data);
        vm.stopPrank();

        assertEq(nftContract.ownerOf(tokenId), buyer);
        assertEq(paymentToken.balanceOf(seller), price);
    }
}
