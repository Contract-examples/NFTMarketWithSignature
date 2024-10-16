// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./MyERC20Token.sol";
import "./IERC20Receiver.sol";

contract NFTMarket is IERC20Receiver {
    using SafeERC20 for MyERC20Token;

    // custom errors
    error NotTheOwner();
    error NFTNotApproved();
    error PriceMustBeGreaterThanZero();
    error NotTheSeller();
    error NFTNotListed();
    error TokenTransferFailed();
    error InvalidToken();
    error InvalidRecipient();
    error InsufficientPayment();
    error NoTokenId();

    struct Listing {
        address seller;
        uint256 price;
    }

    // this is our payment token
    MyERC20Token public immutable paymentToken;
    // this is our NFT contract
    IERC721 public immutable nftContract;

    // this is our listing mapping [tokenId => Listing]
    mapping(uint256 => Listing) public listings;

    // this is our event for when an NFT is listed
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    // this is our event for when an NFT is sold
    event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    // this is our event for when an NFT is unlisted
    event NFTUnlisted(uint256 indexed tokenId);

    constructor(address _nftContract, address _paymentToken) {
        // this is our NFT contract
        nftContract = IERC721(_nftContract);
        // this is our payment token
        paymentToken = MyERC20Token(_paymentToken);
    }

    // this is our function to list an NFT
    function list(uint256 tokenId, uint256 price) external {
        // this is our require statement to check if the NFT is owned by the sender
        if (nftContract.ownerOf(tokenId) != msg.sender) {
            revert NotTheOwner();
        }

        // this is our require statement to check if the NFT is approved
        if (
            nftContract.getApproved(tokenId) != address(this)
                && !nftContract.isApprovedForAll(msg.sender, address(this))
        ) {
            revert NFTNotApproved();
        }

        // this is our require statement to check if the price is greater than zero
        if (price <= 0) {
            revert PriceMustBeGreaterThanZero();
        }

        // add the listing to the mapping
        listings[tokenId] = Listing(msg.sender, price);

        // emit the NFTListed event
        emit NFTListed(tokenId, msg.sender, price);
    }

    // this is our function to unlist an NFT
    function unlist(uint256 tokenId) external {
        // this is our require statement to check if the seller is the sender
        if (listings[tokenId].seller != msg.sender) {
            revert NotTheSeller();
        }

        // remove the listing from the mapping
        delete listings[tokenId];

        // emit the NFTUnlisted event
        emit NFTUnlisted(tokenId);
    }

    // this is our function to buy an NFT
    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        // this is our require statement to check if the NFT is listed
        if (listing.price <= 0) {
            revert NFTNotListed();
        }

        // transfer the payment token to the seller
        paymentToken.safeTransferFrom(msg.sender, listing.seller, listing.price);

        // transfer the NFT to the buyer
        nftContract.safeTransferFrom(listing.seller, msg.sender, tokenId);

        // remove the listing from the mapping
        delete listings[tokenId];

        // emit the NFTSold event
        emit NFTSold(tokenId, listing.seller, msg.sender, listing.price);
    }

    // this is our callback function
    function tokensReceived(address from, address to, uint256 amount, bytes calldata userData) external override returns (bool) {
        // this is our require statement to check if the token is valid
        if (msg.sender != address(paymentToken)) {
            revert InvalidToken();
        }

        // this is our require statement to check if the recipient is valid
        if (to != address(this)) {
            revert InvalidRecipient();
        }

        // this is our require statement to check if the userData is valid
        if (userData.length <= 0) {
            revert NoTokenId();
        }

        // decode userData to get tokenId
        uint256 tokenId = abi.decode(userData, (uint256));

        Listing memory listing = listings[tokenId];
        // this is our require statement to check if the NFT is listed
        if (listing.price <= 0) {
            revert NFTNotListed();
        }

        // this is our require statement to check if the payment is sufficient
        if (amount < listing.price) {
            revert InsufficientPayment();
        }

        // remove the listing from the mapping
        delete listings[tokenId];

        // transfer the payment token to the seller
        paymentToken.safeTransfer(listing.seller, listing.price);

        // transfer the NFT to the buyer
        nftContract.safeTransferFrom(listing.seller, from, tokenId);

        // if the buyer paid more than the price, refund the extra
        if (amount > listing.price) {
            paymentToken.safeTransfer(from, amount - listing.price);
        }

        // emit the NFTSold event
        emit NFTSold(tokenId, listing.seller, from, listing.price);
    }
}
