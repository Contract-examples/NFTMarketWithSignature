// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/NFTMarket.sol";
import "../src/MyERC20Token.sol";
import "../src/MyNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketTest is Test {
    NFTMarket public market;
    MyERC20Token public paymentToken;
    MyNFT public nftContract;

    address public owner;
    address public seller;
    address public seller2;
    address public seller3;
    address public buyer;
    address public buyer2;
    address public buyer3;
    uint256 public tokenId;

    function setUp() public {
        owner = address(this);
        paymentToken = new MyERC20Token();
        // set owner to this contract
        nftContract = new MyNFT(owner);
        market = new NFTMarket(address(nftContract), address(paymentToken));

        seller = address(0x1);
        seller2 = address(0x2);
        seller3 = address(0x3);
        buyer = address(0x4);
        buyer2 = address(0x5);
        buyer3 = address(0x6);

        // give buyer 1000 tokens
        paymentToken.mint(buyer, 1000 * 10 ** 18);

        // mock owner
        vm.prank(owner);
        // let owner mint nft to seller
        nftContract.safeMint(seller, "ipfs://test-url-001");
        nftContract.safeMint(seller2, "ipfs://test-url-002");
        nftContract.safeMint(seller3, "ipfs://test-url-003");

        // get actual tokenId
        // seller
        {
            uint256 i = 0; // set id = 0
            uint256 currentTokenId = nftContract.tokenOfOwnerByIndex(seller, i);
            console2.log("Index: %s, Minted NFT with ID: %s", i, currentTokenId);
            console2.log("NFT owner:", nftContract.ownerOf(currentTokenId));
        }
        // seller2
        {
            uint256 i = 0; // set id = 0
            uint256 currentTokenId = nftContract.tokenOfOwnerByIndex(seller2, i);
            console2.log("Index: %s, Minted NFT with ID: %s", i, currentTokenId);
            console2.log("NFT owner:", nftContract.ownerOf(currentTokenId));
        }
        // seller3
        {
            uint256 i = 0; // set id = 0
            uint256 currentTokenId = nftContract.tokenOfOwnerByIndex(seller3, i);
            console2.log("Index: %s, Minted NFT with ID: %s", i, currentTokenId);
            console2.log("NFT owner:", nftContract.ownerOf(currentTokenId));
        }
    }

    function testListNFT() public {
        // seller
        {
            // nft price
            uint256 price = 100 * 10 ** 18;

            // mock seller
            vm.startPrank(seller);

            // seller's nft tokenId is 0
            tokenId = 0;

            // approve nft-market to transfer nft by tokenId
            nftContract.approve(address(market), tokenId);

            // list nft
            market.list(tokenId, price);

            vm.stopPrank(); // stop prank

            (address listedSeller, uint256 listedPrice) = market.listings(tokenId);
            console2.log("seller: listedSeller:", listedSeller);
            console2.log("seller: listedPrice:", listedPrice);
            assertEq(listedSeller, seller);
            assertEq(listedPrice, price);
        }

        // seller2
        {
            // nft price
            uint256 price = 100 * 10 ** 18;

            // mock seller2
            vm.startPrank(seller2);

            // seller2's nft tokenId is 1
            tokenId = 1;

            // approve nft-market to transfer nft by tokenId
            nftContract.approve(address(market), tokenId);

            // list nft
            market.list(tokenId, price);

            vm.stopPrank();

            (address listedSeller, uint256 listedPrice) = market.listings(tokenId);
            console2.log("seller2: listedSeller:", listedSeller);
            console2.log("seller2: listedPrice:", listedPrice);
            assertEq(listedSeller, seller2);
            assertEq(listedPrice, price);
        }

        // seller3
        {
            // nft price
            uint256 price = 100 * 10 ** 18;

            // mock seller3
            vm.startPrank(seller3);

            // seller3's nft tokenId is 2
            tokenId = 2;

            // approve nft-market to transfer nft by tokenId
            nftContract.approve(address(market), tokenId);

            // list nft
            market.list(tokenId, price);

            vm.stopPrank();

            (address listedSeller, uint256 listedPrice) = market.listings(tokenId);
            console2.log("seller3: listedSeller:", listedSeller);
            console2.log("seller3: listedPrice:", listedPrice);
            assertEq(listedSeller, seller3);
            assertEq(listedPrice, price);
        }
    }

    // function testBuyNFT() public {
    //     uint256 price = 100 * 10 ** 18;

    //     vm.startPrank(seller);
    //     nftContract.approve(address(market), tokenId);

    //     // list nft
    //     market.list(tokenId, price);
    //     vm.stopPrank();

    //     // buyer buy nft
    //     vm.startPrank(buyer);
    //     paymentToken.approve(address(market), price);
    //     market.buyNFT(tokenId);
    //     vm.stopPrank();

    //     assertEq(nftContract.ownerOf(tokenId), buyer);
    //     assertEq(paymentToken.balanceOf(seller), price);
    // }

    // function testUnlistNFT() public {
    //     uint256 price = 100 * 10 ** 18;

    //     vm.startPrank(seller);
    //     nftContract.approve(address(market), tokenId);
    //     // list nft
    //     market.list(tokenId, price);
    //     // unlist nft
    //     market.unlist(tokenId);
    //     vm.stopPrank();

    //     (address listedSeller, uint256 listedPrice) = market.listings(tokenId);
    //     assertEq(listedSeller, address(0));
    //     assertEq(listedPrice, 0);
    // }

    // function testTokensReceivedHook() public {
    //     uint256 price = 100 * 10 ** 18;

    //     // list nft
    //     vm.startPrank(seller);
    //     nftContract.approve(address(market), tokenId);
    //     market.list(tokenId, price);
    //     vm.stopPrank();

    //     // buyer transfer to market contract
    //     vm.startPrank(buyer);
    //     bytes memory data = abi.encode(tokenId);
    //     paymentToken.transferAndCall(address(market), price, data);
    //     vm.stopPrank();

    //     assertEq(nftContract.ownerOf(tokenId), buyer);
    //     assertEq(paymentToken.balanceOf(seller), price);
    // }
}
