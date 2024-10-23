// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/MyNFT.sol";

contract MyNFTTest is Test {
    MyNFT public nft;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        nft = new MyNFT("MyNFT", "MFT", 1000);
    }

    function testInitialState() public {
        assertEq(nft.name(), "MyNFT");
        assertEq(nft.symbol(), "MFT");
        assertEq(nft.MintSupplyForUsers(), 0);
    }

    function testSafeMint() public {
        vm.prank(owner);
        nft.safeMint(user1, "ipfs://test-uri-1");

        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.tokenURI(0), "ipfs://test-uri-1");
        assertEq(nft.MintSupplyForUsers(), 0);
    }

    function testSafeMintForUsers() public {
        vm.prank(user1);
        nft.safeMintForUsers(user1, "ipfs://test-uri-2");

        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(0), user1);
        assertEq(nft.tokenURI(0), "ipfs://test-uri-2");
        assertEq(nft.MintSupplyForUsers(), 1);
    }

    function testMaxSupply() public {
        for (uint256 i = 0; i < 1000; i++) {
            vm.prank(user1);
            nft.safeMintForUsers(user1, string(abi.encodePacked("ipfs://test-uri-", vm.toString(i))));
        }

        assertEq(nft.MintSupplyForUsers(), 1000);

        vm.expectRevert(MyNFT.maxSupplyReached.selector);
        vm.prank(user2);
        nft.safeMintForUsers(user2, "ipfs://test-uri-1001");
    }

    function testOnlyOwnerCanSafeMint() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        nft.safeMint(user1, "ipfs://test-uri-3");
    }

    function testSupportsInterface() public {
        assertTrue(nft.supportsInterface(type(IERC721).interfaceId));
        assertTrue(nft.supportsInterface(type(IERC721Metadata).interfaceId));
        assertTrue(nft.supportsInterface(type(IERC721Enumerable).interfaceId));
    }
}
