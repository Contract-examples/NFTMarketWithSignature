// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 private NextTokenId;
    uint256 public MaxSupply;
    uint256 public MintSupplyForUsers;

    error maxSupplyReached();

    constructor(string memory name, string memory symbol, uint256 maxSupply) ERC721(name, symbol) Ownable(msg.sender) {
        MaxSupply = maxSupply;
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        if (NextTokenId >= MaxSupply) {
            revert maxSupplyReached();
        }

        uint256 tokenId = NextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following function for self mint without owner legibility
    function safeMintForUsers(address to, string memory uri) public {
        if (NextTokenId >= MaxSupply) {
            revert maxSupplyReached();
        }

        uint256 tokenId = NextTokenId++;
        MintSupplyForUsers++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.
    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
