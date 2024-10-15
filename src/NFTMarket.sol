// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MyERC20Token.sol";

contract NFTMarket is ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct Listing {
        address seller;
        uint256 price;
    }

    MyERC20Token public immutable paymentToken;
    IERC721 public immutable nftContract;

    mapping(uint256 => Listing) public listings;

    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    event NFTUnlisted(uint256 indexed tokenId);

    constructor(address _nftContract, address _paymentToken) {
        nftContract = IERC721(_nftContract);
        paymentToken = MyERC20Token(_paymentToken);
    }

    function list(uint256 tokenId, uint256 price) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(nftContract.getApproved(tokenId) == address(this) || nftContract.isApprovedForAll(msg.sender, address(this)), "NFT not approved");
        require(price > 0, "Price must be greater than zero");

        listings[tokenId] = Listing(msg.sender, price);
        emit NFTListed(tokenId, msg.sender, price);
    }

    function unlist(uint256 tokenId) external {
        require(listings[tokenId].seller == msg.sender, "Not the seller");
        delete listings[tokenId];
        emit NFTUnlisted(tokenId);
    }

    function buyNFT(uint256 tokenId) external nonReentrant {
        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "NFT not listed");

        delete listings[tokenId];

        paymentToken.safeTransferFrom(msg.sender, listing.seller, listing.price);
        nftContract.safeTransferFrom(listing.seller, msg.sender, tokenId);

        emit NFTSold(tokenId, listing.seller, msg.sender, listing.price);
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        require(msg.sender == address(paymentToken), "Invalid token");
        require(to == address(this), "Invalid recipient");

        // 解码userData以获取tokenId
        uint256 tokenId = abi.decode(userData, (uint256));

        Listing memory listing = listings[tokenId];
        require(listing.price > 0, "NFT not listed");
        require(amount >= listing.price, "Insufficient payment");

        delete listings[tokenId];

        // 将代币转给卖家
        paymentToken.safeTransfer(listing.seller, listing.price);

        // 将NFT转给买家
        nftContract.safeTransferFrom(listing.seller, from, tokenId);

        // 如果支付了超过价格的代币,退还多余的部分
        if (amount > listing.price) {
            paymentToken.safeTransfer(from, amount - listing.price);
        }

        emit NFTSold(tokenId, listing.seller, from, listing.price);
    }
}
