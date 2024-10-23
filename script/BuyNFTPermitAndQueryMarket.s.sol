// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/NFTMarket.sol";
import "../src/MyNFT.sol";
import "../src/MyERC20PermitToken.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract BuyNFTPermitAndQueryMarketScript is Script {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    uint256 public whitelistBuyerPrivateKey;
    uint256 public whitelistSignerPrivateKey;
    address public whitelistBuyer;
    address public whitelistSigner;

    address public marketAddress;
    address public nftAddress;
    address public tokenAddress;

    NFTMarket public market;
    MyNFT public nft;
    MyERC20PermitToken public paymentToken;

    uint256 public tokenId;

    function run() external {
        whitelistBuyerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY2");
        whitelistSignerPrivateKey = vm.envUint("SEPOLIA_WALLET_PRIVATE_KEY");
        whitelistBuyer = vm.addr(whitelistBuyerPrivateKey);
        whitelistSigner = vm.addr(whitelistSignerPrivateKey);

        console2.log("whitelistBuyer: %s", Strings.toHexString((whitelistBuyer)));
        console2.log("whitelistSigner: %s", Strings.toHexString((whitelistSigner)));

        // replace your nft market contract address
        marketAddress = 0x98A566801FF66d156971ADa3f6D729eFBABD67Ca;
        // replace your nft contract address
        nftAddress = 0x32eCC13478b2d03b212AE7b371F5f3C18490Bc9d;
        // replace your payment token contract address
        tokenAddress = 0x6343c4a548F5f75b47Cdd1A52a52eF89bC29A5eB;

        market = NFTMarket(marketAddress);
        nft = MyNFT(nftAddress);
        paymentToken = MyERC20PermitToken(tokenAddress);

        tokenId = 1;

        vm.startBroadcast(whitelistBuyerPrivateKey);

        (address seller, uint256 price) = market.listings(tokenId);
        console2.log("NFT seller:", seller);
        console2.log("NFT price:", price);

        // Generate whitelist signature
        bytes32 messageHash = keccak256(abi.encodePacked(whitelistBuyer, tokenId));
        console2.log("messageHash: %s", Strings.toHexString(uint256(messageHash)));

        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        console2.log("ethSignedMessageHash: %s", Strings.toHexString(uint256(ethSignedMessageHash)));

        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(whitelistSignerPrivateKey, ethSignedMessageHash);
        console2.log("v1: %s", Strings.toHexString(uint256(v1)));
        console2.log("r1: %s", Strings.toHexString(uint256(r1)));
        console2.log("s1: %s", Strings.toHexString(uint256(s1)));

        bytes memory whitelistSignature = abi.encodePacked(r1, s1, v1);
        console2.log("whitelistSignature: ");
        console2.logBytes(whitelistSignature);

        // Generate ERC2612 permit signature
        uint256 deadline = block.timestamp + 1 hours;
        bytes32 permitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                paymentToken.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        whitelistBuyer,
                        marketAddress,
                        price,
                        paymentToken.nonces(whitelistBuyer),
                        deadline
                    )
                )
            )
        );
        console2.log("permitHash: %s", Strings.toHexString(uint256(permitHash)));

        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(whitelistBuyerPrivateKey, permitHash);
        console2.log("v2: %s", Strings.toHexString(uint256(v2)));
        console2.log("r2: %s", Strings.toHexString(uint256(r2)));
        console2.log("s2: %s", Strings.toHexString(uint256(s2)));

        vm.stopBroadcast();

        // execute permitBuy
        vm.prank(whitelistBuyer);
        try market.permitBuy(tokenId, price, deadline, v2, r2, s2, whitelistSignature) {
            console2.log("Transaction successful");
        } catch Error(string memory reason) {
            console2.log("Transaction failed. Reason:", reason);
        } catch {
            console2.log("Transaction failed with no reason string");
        }

        console2.log("NFT purchased:");
        console2.log("whitelistBuyer:", whitelistBuyer);
        console2.log("Token ID:", tokenId);
        console2.log("Price paid:", price);

        // Query market status
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
