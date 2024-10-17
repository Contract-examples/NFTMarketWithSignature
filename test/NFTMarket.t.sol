// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../src/NFTMarket.sol";
import "../src/MyERC20Token.sol";
import "../src/MyNFT.sol";

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

    mapping(address => string) private addressLabels;

    // get address label
    function getAddressLabel(address addr) internal view returns (string memory) {
        string memory label = addressLabels[addr];
        if (bytes(label).length == 0) {
            // if not set, return hex string
            return Strings.toHexString(uint160(addr), 20);
        }
        // if set, return label
        return string(abi.encodePacked(label, " (", Strings.toHexString(uint160(addr), 20), ")"));
    }

    function setUp() public {
        owner = address(this);
        paymentToken = new MyERC20Token();
        // set owner to this contract
        nftContract = new MyNFT(owner);
        market = new NFTMarket(address(nftContract), address(paymentToken));

        // make address
        seller = makeAddr("seller");
        seller2 = makeAddr("seller2");
        seller3 = makeAddr("seller3");
        buyer = makeAddr("buyer");
        buyer2 = makeAddr("buyer2");
        buyer3 = makeAddr("buyer3");

        // set label
        addressLabels[owner] = "owner";
        addressLabels[seller] = "seller";
        addressLabels[seller2] = "seller2";
        addressLabels[seller3] = "seller3";
        addressLabels[buyer] = "buyer";
        addressLabels[buyer2] = "buyer2";
        addressLabels[buyer3] = "buyer3";

        // give buyer/buyer2/buyer3 1000 tokens
        paymentToken.mint(buyer, 1000 * 10 ** paymentToken.decimals());
        paymentToken.mint(buyer2, 1000 * 10 ** paymentToken.decimals());
        paymentToken.mint(buyer3, 1000 * 10 ** paymentToken.decimals());

        // mock owner
        vm.prank(owner);
        
        // let owner mint nft to seller
        nftContract.safeMint(seller, "ipfs://test-url-001");
        nftContract.safeMint(seller2, "ipfs://test-url-002");
        nftContract.safeMint(seller3, "ipfs://test-url-003");

        // get actual tokenId
        // seller
        {
            uint256 i = 0; // set idx = 0
            uint256 currentTokenId = nftContract.tokenOfOwnerByIndex(seller, i);
            console2.log("Index: %s, Minted NFT with ID: %s", i, currentTokenId);
            console2.log("NFT owner:", getAddressLabel(nftContract.ownerOf(currentTokenId)));
        }
        // seller2
        {
            uint256 i = 0; // set idx = 0
            uint256 currentTokenId = nftContract.tokenOfOwnerByIndex(seller2, i);
            console2.log("Index: %s, Minted NFT with ID: %s", i, currentTokenId);
            console2.log("NFT owner:", getAddressLabel(nftContract.ownerOf(currentTokenId)));
        }
        // seller3
        {
            uint256 i = 0; // set idx = 0
            uint256 currentTokenId = nftContract.tokenOfOwnerByIndex(seller3, i);
            console2.log("Index: %s, Minted NFT with ID: %s", i, currentTokenId);
            console2.log("NFT owner:", getAddressLabel(nftContract.ownerOf(currentTokenId)));
        }
    }

    function testListNFT() public {
        // seller
        {
            // nft price
            uint256 price = 100 * 10 ** paymentToken.decimals();

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
            console2.log("seller: listedSeller:", getAddressLabel(listedSeller));
            console2.log("seller: listedPrice:", listedPrice);
            assertEq(listedSeller, seller);
            assertEq(listedPrice, price);
        }

        // seller2
        {
            // nft price
            uint256 price = 100 * 10 ** paymentToken.decimals();

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
            console2.log("seller2: listedSeller:", getAddressLabel(listedSeller));
            console2.log("seller2: listedPrice:", listedPrice);
            assertEq(listedSeller, seller2);
            assertEq(listedPrice, price);
        }

        // seller3
        {
            // nft price
            uint256 price = 100 * 10 ** paymentToken.decimals();

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
            console2.log("seller3: listedSeller:", getAddressLabel(listedSeller));
            console2.log("seller3: listedPrice:", listedPrice);
            assertEq(listedSeller, seller3);
            assertEq(listedPrice, price);
        }
    }

    function testListNotOwner() public {
        // nft price
        uint256 price = 100 * 10 ** paymentToken.decimals();

        // mock seller
        vm.startPrank(seller);

        // seller's nft tokenId is 0
        // we set 1 to test "not owner"
        tokenId = 1;

        // approve nft-market to transfer nft by tokenId
        nftContract.approve(address(market), tokenId);

        // set expect revert
        vm.expectRevert(NFTMarket.NotTheOwner.selector);

        // list nft
        market.list(tokenId, price);

        vm.stopPrank();
    }

    function testListNFTNotApproved() public {
        // nft price
        uint256 price = 100 * 10 ** paymentToken.decimals();

        // mock seller
        vm.startPrank(seller);

        // seller's nft tokenId is 0
        tokenId = 0;

        // set expect revert
        vm.expectRevert(NFTMarket.NFTNotApproved.selector);

        // list nft
        market.list(tokenId, price);

        vm.stopPrank();
    }

    function testListNFTZeroPrice() public {
        // nft price
        uint256 price = 0;

        // mock seller
        vm.startPrank(seller);

        // seller's nft tokenId is 0
        tokenId = 0;

        // approve nft-market to transfer nft by tokenId
        nftContract.approve(address(market), tokenId);

        // set expect revert
        vm.expectRevert(NFTMarket.PriceMustBeGreaterThanZero.selector);

        // list nft
        market.list(tokenId, price);

        vm.stopPrank();
    }

    function testListEmitEvent() public {
        // nft price
        uint256 price = 100 * 10 ** paymentToken.decimals();

        // mock seller
        vm.startPrank(seller);

        // seller's nft tokenId is 0
        tokenId = 0;

        // approve nft-market to transfer nft by tokenId
        nftContract.approve(address(market), tokenId);

        // expect emit NFTListed event
        vm.expectEmit(true, true, false, true);
        emit NFTMarket.NFTListed(tokenId, seller, price);

        // list nft
        market.list(tokenId, price);

        vm.stopPrank();
    }

    function testUnlistNFT() public {
        uint256 price = 100 * 10 ** paymentToken.decimals();

        // seller's nft tokenId is 0
        tokenId = 0;

        vm.startPrank(seller);

        // approve nft-market to transfer nft by tokenId
        nftContract.approve(address(market), tokenId);

        // list nft
        market.list(tokenId, price);

        // unlist nft
        market.unlist(tokenId);

        vm.stopPrank();

        (address listedSeller, uint256 listedPrice) = market.listings(tokenId);
        console2.log("listedSeller:", getAddressLabel(listedSeller));
        console2.log("listedPrice:", listedPrice);
        assertEq(listedSeller, address(0));
        assertEq(listedPrice, 0);
    }

    function testUnlistNFTNotTheSeller() public {
        uint256 price = 100 * 10 ** paymentToken.decimals();

        // seller's nft tokenId is 0
        tokenId = 0;

        vm.startPrank(seller);

        // approve nft-market to transfer nft by tokenId
        nftContract.approve(address(market), tokenId);

        // list nft
        market.list(tokenId, price);

        // test unlist nft by not owner
        tokenId = 1;
        // set expect revert
        vm.expectRevert(NFTMarket.NotTheSeller.selector);
        // unlist nft
        market.unlist(tokenId);

        vm.stopPrank();
    }

    function testUnlistNFTEmitEvent() public {
        uint256 price = 100 * 10 ** paymentToken.decimals();

        // seller's nft tokenId is 0
        tokenId = 0;

        vm.startPrank(seller);

        // approve nft-market to transfer nft by tokenId
        nftContract.approve(address(market), tokenId);

        // list nft
        market.list(tokenId, price);

        // expect emit NFTUnlisted event
        vm.expectEmit(true, false, false, false);
        emit NFTMarket.NFTUnlisted(tokenId);

        // unlist nft
        market.unlist(tokenId);

        vm.stopPrank();
    }

    function testBuyNFT() public {
        uint256 price = 200 * 10 ** paymentToken.decimals();

        vm.startPrank(seller);

        // seller's nft tokenId is 0
        tokenId = 0;

        // approve nft-market to transfer nft by tokenId
        nftContract.approve(address(market), tokenId);

        // list nft
        market.list(tokenId, price);
        vm.stopPrank();

        // buyer buy nft
        vm.startPrank(buyer);
        paymentToken.approve(address(market), price);
        market.buyNFT(tokenId);
        vm.stopPrank();

        console2.log("nftContract.ownerOf(tokenId):", getAddressLabel(nftContract.ownerOf(tokenId)));
        console2.log("buyer:", getAddressLabel(buyer));
        console2.log("paymentToken.balanceOf(seller):", paymentToken.balanceOf(seller));
        console2.log("price:", price);

        assertEq(nftContract.ownerOf(tokenId), buyer);
        assertEq(paymentToken.balanceOf(seller), price);
    }

    function testBuyNFTCallback() public {
        uint256 price = 100 * 10 ** paymentToken.decimals();

        // seller's nft tokenId is 0
        tokenId = 0;

        // list nft
        vm.startPrank(seller);
        nftContract.approve(address(market), tokenId);
        market.list(tokenId, price);
        vm.stopPrank();

        // buyer transfer to market contract
        vm.startPrank(buyer);
        bytes memory data = abi.encode(tokenId);

        // use paymentToken to get nft
        paymentToken.transferAndCall(address(market), price, data);
        vm.stopPrank();

        console2.log("nftContract.ownerOf(tokenId):", getAddressLabel(nftContract.ownerOf(tokenId)));
        console2.log("buyer:", getAddressLabel(buyer));
        console2.log("paymentToken.balanceOf(seller):", paymentToken.balanceOf(seller));
        console2.log("price:", price);

        assertEq(nftContract.ownerOf(tokenId), buyer);
        assertEq(paymentToken.balanceOf(seller), price);
    }
}
