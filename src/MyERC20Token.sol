// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITokenReceiver {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    )
        external;
}

// ERC20Burnable: burnable token
// Pausable: pausable token
// Ownable: only owner can mint and burn
contract MyERC20Token is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("MyNFTToken", "MTK") {
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    // only owner can pause
    function pause() public onlyOwner {
        _pause();
    }

    // only owner can unpause
    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override {
        super._afterTokenTransfer(from, to, amount);
        if (to != address(0)) {
            try ITokenReceiver(to).tokensReceived(msg.sender, from, to, amount, "", "") { } catch { }
        }
    }
}
