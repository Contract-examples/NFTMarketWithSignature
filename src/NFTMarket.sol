// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@solady/utils/SafeTransferLib.sol";
import "./IERC20Receiver.sol";

contract NFTMarket is IERC20Receiver, Ownable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

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
    error InvalidSeller();
    error NotSignedByWhitelistSigner();
    error PermitNotSupported();
    error InvalidWhitelistSigner();
    error SignatureExpired();
    error InvalidSignature();
    error NFTAlreadyRented();
    error RentNotAvailable();
    error RentNotExpired();
    error NFTAlreadyListed();
    error RentDurationMustBeGreaterThanZero();

    // custom events
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    event NFTUnlisted(uint256 indexed tokenId);
    event Refund(address indexed from, uint256 amount);
    event WhitelistBuy(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event NFTRented(uint256 indexed tokenId, address indexed renter, uint256 duration, uint256 price);
    event NFTRetrieved(uint256 indexed tokenId, address indexed seller);
    event NFTListedWithSignature(uint256 indexed tokenId, address indexed seller, uint256 price, uint256 deadline);

    // custom structs
    struct Listing {
        address seller;
        uint256 price;
    }

    struct SignedListing {
        address seller;
        uint256 price;
        uint256 deadline;
        bool isValid;
    }

    struct RentInfo {
        address renter;
        uint256 startTime;
        uint256 duration;
        uint256 price;
    }

    // this is our payment token
    IERC20 public immutable paymentToken;
    // this is our payment token permit
    IERC20Permit public immutable paymentTokenPermit;
    // indicate if the payment token supports permit(EIP-2612)
    bool public immutable supportsPermit;
    // this is our NFT contract
    IERC721 public immutable nftContract;
    // this is our whitelist signer
    address public whitelistSigner;

    // this is our listing mapping [tokenId => Listing]
    mapping(uint256 => Listing) public listings;
    mapping(uint256 => SignedListing) public signedListings;
    mapping(uint256 => RentInfo) public rentals;
    mapping(bytes32 => bool) public usedSignatures;

    constructor(address _nftContract, address _paymentToken) Ownable(msg.sender) {
        nftContract = IERC721(_nftContract);
        paymentToken = IERC20(_paymentToken);

        // check if the payment token supports permit
        supportsPermit = _isPermitSupported(_paymentToken);
        if (supportsPermit) {
            paymentTokenPermit = IERC20Permit(_paymentToken);
        }

        // default whitelist signer is the owner
        whitelistSigner = msg.sender;
    }

    // this is a function to set the whitelist signer
    function setWhitelistSigner(address _whitelistSigner) external onlyOwner {
        if (_whitelistSigner == address(0)) {
            revert InvalidWhitelistSigner();
        }
        whitelistSigner = _whitelistSigner;
    }

    // this is a helper function to check if the recipient is a contract
    function _isContract(address account) internal view returns (bool) {
        // if the code size is greater than 0, then the account is a contract
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    // check if the token supports permit
    function _isPermitSupported(address _token) internal view returns (bool) {
        if (!_isContract(_token)) {
            return false;
        }
        try IERC20Permit(_token).DOMAIN_SEPARATOR() returns (bytes32) {
            return true;
        } catch {
            return false;
        }
    }

    // this is our function to list an NFT
    function list(uint256 tokenId, uint256 price) external {
        // make sure the sender is the owner of the NFT
        if (nftContract.ownerOf(tokenId) != msg.sender) {
            revert NotTheOwner();
        }

        // make sure the NFT is approved for the NFTMarket contract
        bool isIndividuallyApproved = nftContract.getApproved(tokenId) == address(this);
        bool isApprovedForAll = nftContract.isApprovedForAll(msg.sender, address(this));
        if (!isIndividuallyApproved && !isApprovedForAll) {
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
        SafeTransferLib.safeTransferFrom(address(paymentToken), msg.sender, listing.seller, listing.price);

        // transfer NFT from seller to buyer
        _safeTransferFromSellerToBuyer(tokenId, msg.sender);

        // emit the NFTSold event
        emit NFTSold(tokenId, listing.seller, msg.sender, listing.price);
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
        // make sure the sender is the payment token
        if (msg.sender != address(paymentToken)) {
            revert InvalidToken();
        }
        // make sure the recipient is the NFTMarket contract
        if (to != address(this)) {
            revert InvalidRecipient();
        }

        // make sure the userData is 32 bytes
        if (userData.length != 32) {
            revert NoTokenId();
        }

        // decode the userData to get the tokenId
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
            SafeTransferLib.safeTransfer(address(paymentToken), from, refundAmount);
            // emit the Refund event
            emit Refund(from, refundAmount);
        }

        // transfer the payment token to the seller
        SafeTransferLib.safeTransfer(address(paymentToken), listing.seller, listing.price);

        // transfer NFT from seller to buyer
        _safeTransferFromSellerToBuyer(tokenId, from);

        // emit the NFTSold event
        emit NFTSold(tokenId, listing.seller, from, listing.price);

        return true;
    }

    // this is our private function to transfer NFT from seller to buyer
    function _safeTransferFromSellerToBuyer(uint256 tokenId, address buyer) private {
        Listing memory listing = listings[tokenId];
        // transfer NFT from seller to buyer
        nftContract.safeTransferFrom(listing.seller, buyer, tokenId);
        // delete the listing
        delete listings[tokenId];
    }

    // need to be whitelisted to buy
    function permitBuy(
        uint256 tokenId,
        uint256 price,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory whitelistSignature
    )
        external
    {
        // make sure the payment token supports permit
        if (!supportsPermit) {
            revert PermitNotSupported();
        }

        Listing memory listing = listings[tokenId];
        // make sure the NFT is listed
        if (listing.price == 0) {
            revert NFTNotListed();
        }
        // make sure the buyer is not the seller
        if (msg.sender == listing.seller) {
            revert TheSenderIsTheSeller();
        }

        // verify the whitelist signature
        bytes32 messageHash = keccak256(abi.encodePacked(msg.sender, tokenId));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        address signer = ethSignedMessageHash.recover(whitelistSignature);

        // not signed by the whitelist signer
        if (signer != whitelistSigner) {
            revert NotSignedByWhitelistSigner();
        }

        // use the permit function of ERC2612
        paymentTokenPermit.permit(msg.sender, address(this), price, deadline, v, r, s);

        // transfer the payment token to the seller
        SafeTransferLib.safeTransferFrom(address(paymentToken), msg.sender, listing.seller, price);

        // transfer NFT from seller to buyer
        _safeTransferFromSellerToBuyer(tokenId, msg.sender);

        // emit the WhitelistBuy event
        emit WhitelistBuy(tokenId, msg.sender, price);
    }

    // list an NFT with a signature
    function listWithSignature(uint256 tokenId, uint256 price, uint256 deadline, bytes memory signature) external {
        // check deadline
        if (deadline < block.timestamp) revert SignatureExpired();

        // check price
        if (price == 0) revert PriceMustBeGreaterThanZero();

        // check if NFT is already listed (both regular and signed listings)
        if (listings[tokenId].price > 0) revert NFTAlreadyListed();
        if (signedListings[tokenId].isValid) revert NFTAlreadyListed();

        // create message hash
        bytes32 messageHash = keccak256(abi.encodePacked(address(this), tokenId, price, deadline, block.chainid));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        // recover the signer
        address signer = ethSignedMessageHash.recover(signature);

        // the signer is not the owner of the NFT
        if (signer != nftContract.ownerOf(tokenId)) revert InvalidSignature();

        // add the signed listing to the mapping
        signedListings[tokenId] = SignedListing({ seller: signer, price: price, deadline: deadline, isValid: true });

        // emit the NFTListedWithSignature event
        emit NFTListedWithSignature(tokenId, signer, price, deadline);
    }

    // rent an NFT
    function rentNFT(uint256 tokenId, uint256 duration) external payable {
        Listing memory listing = listings[tokenId];
        if (listing.price == 0) revert NFTNotListed();
        if (duration == 0) revert RentDurationMustBeGreaterThanZero();

        // the NFT is already rented
        if (rentals[tokenId].renter != address(0)) revert NFTAlreadyRented();

        uint256 rentPrice = listing.price * duration;
        if (msg.value < rentPrice) revert InsufficientPayment();

        // transfer the rent price to the seller
        (bool success,) = listing.seller.call{ value: rentPrice }("");
        if (!success) revert TokenTransferFailed();

        // if the buyer paid more than the rent price, refund the extra
        if (msg.value > rentPrice) {
            (bool refundSuccess,) = msg.sender.call{ value: msg.value - rentPrice }("");
            if (!refundSuccess) revert TokenTransferFailed();
        }

        // record the rental info
        rentals[tokenId] =
            RentInfo({ renter: msg.sender, startTime: block.timestamp, duration: duration, price: rentPrice });

        // transfer the NFT to the market contract
        nftContract.safeTransferFrom(listing.seller, address(this), tokenId);

        // emit the NFTRented event
        emit NFTRented(tokenId, msg.sender, duration, rentPrice);
    }

    // retrieve a rented NFT(seller want to retrieve the rented NFT)
    function retrieveRentedNFT(uint256 tokenId) external {
        RentInfo memory rental = rentals[tokenId];
        if (rental.renter == address(0)) revert RentNotAvailable();

        // check if the rent is expired
        if (block.timestamp < rental.startTime + rental.duration) revert RentNotExpired();

        // check if the sender is the seller
        address seller = listings[tokenId].seller;
        if (msg.sender != seller) revert NotTheOwner();

        // return the NFT to the seller
        nftContract.safeTransferFrom(address(this), seller, tokenId);

        // clear the rental info
        delete rentals[tokenId];

        // emit the NFTRetrieved event
        emit NFTRetrieved(tokenId, seller);
    }

    // get the active listings
    function getActiveListings() external view returns (uint256[] memory tokenIds, Listing[] memory activeListings) {
        // Cache the total supply to save gas
        uint256 totalSupply = IERC721Enumerable(address(nftContract)).totalSupply();

        // Cache the current timestamp to save gas
        uint256 currentTime = block.timestamp;

        // Create dynamic arrays in memory
        tokenIds = new uint256[](totalSupply);
        activeListings = new Listing[](totalSupply);

        // Track valid listings count
        uint256 activeCount;

        // Single loop to check both regular and signed listings
        for (uint256 i; i < totalSupply;) {
            // Cache storage reads
            Listing memory regularListing = listings[i];
            SignedListing memory signedListing = signedListings[i];

            // Check if there's a valid listing
            if (regularListing.price > 0) {
                tokenIds[activeCount] = i;
                activeListings[activeCount] = regularListing;
                // disable overflow check
                unchecked {
                    ++activeCount;
                }
            } else if (signedListing.isValid && signedListing.deadline > currentTime) {
                tokenIds[activeCount] = i;
                activeListings[activeCount] = Listing(signedListing.seller, signedListing.price);
                // disable overflow check
                unchecked {
                    ++activeCount;
                }
            }

            // disable overflow check
            unchecked {
                ++i;
            }
        }

        // Resize arrays to actual count
        assembly {
            mstore(tokenIds, activeCount)
            mstore(activeListings, activeCount)
        }
    }
}
