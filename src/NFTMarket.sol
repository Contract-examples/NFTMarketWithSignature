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
    error NotSellerOrNotListed();
    error NFTNotListed();
    error TokenTransferFailed();
    error InvalidToken();
    error InvalidRecipient();
    error InsufficientPayment();
    error NoTokenId();
    error TheSenderIsTheSeller();

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
        // make sure the sender is the owner of the NFT
        if (nftContract.ownerOf(tokenId) != msg.sender) {
            revert NotTheOwner();
        }

        // make sure the NFT is approved for the NFTMarket contract
        if (
            nftContract.getApproved(tokenId) != address(this)
                && !nftContract.isApprovedForAll(msg.sender, address(this))
        ) {
            revert NFTNotApproved();
        }

        // make sure the price is not zero
        if (price == 0) {
            revert PriceMustBeGreaterThanZero();
        }

        // add the listing to the mapping
        listings[tokenId] = Listing(msg.sender, price);

        // emit the NFTListed event
        emit NFTListed(tokenId, msg.sender, price);
    }

    // this is our function to unlist an NFT
    function unlist(uint256 tokenId) external {
        // make sure the sender is the seller of the NFT
        if (listings[tokenId].seller != msg.sender) {
            revert NotSellerOrNotListed();
        }

        // remove the listing from the mapping
        delete listings[tokenId];

        // emit the NFTUnlisted event
        emit NFTUnlisted(tokenId);
    }

    // this is our function to buy an NFT
    function buyNFT(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        // make sure the NFT is listed
        if (listing.price == 0) {
            revert NFTNotListed();
        }
        // make sure the sender is not the seller
        if (msg.sender == listing.seller) {
            revert TheSenderIsTheSeller();
        }

        // transfer the payment token to the seller
        paymentToken.safeTransferFrom(msg.sender, listing.seller, listing.price);

        // transfer NFT from seller to buyer
        _safeTransferFromSellerToBuyer(tokenId, msg.sender, listing.price);
    }

    // this is our callback function
    function tokensReceived(
        address from,
        address to,
        uint256 amount,
        bytes calldata userData
    )
        external
        override
        returns (bool)
    {
        if (msg.sender != address(paymentToken)) {
            revert InvalidToken();
        }
        if (to != address(this)) {
            revert InvalidRecipient();
        }

        // make sure the userData is 32 bytes
        if (userData.length != 32) {
            revert NoTokenId();
        }

        uint256 tokenId = abi.decode(userData, (uint256));
        Listing memory listing = listings[tokenId];

        // make sure the NFT is listed
        if (listing.price == 0) {
            revert NFTNotListed();
        }
        if (amount < listing.price) {
            revert InsufficientPayment();
        }

        // if the buyer paid more than the price, refund the extra
        uint256 refundAmount = amount > listing.price ? amount - listing.price : 0;
        if (refundAmount != 0) {
            paymentToken.safeTransfer(from, refundAmount);
        }

        // transfer the payment token to the seller
        paymentToken.safeTransfer(listing.seller, listing.price);

        // transfer NFT from seller to buyer
        _safeTransferFromSellerToBuyer(tokenId, from, listing.price);

        return true;
    }

    // this is our internal function to transfer NFT from seller to buyer
    function _safeTransferFromSellerToBuyer(uint256 tokenId, address buyer, uint256 price) internal {
        Listing memory listing = listings[tokenId];
        nftContract.safeTransferFrom(listing.seller, buyer, tokenId);
        delete listings[tokenId];
        emit NFTSold(tokenId, listing.seller, buyer, price);
    }
}
