// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ITokenReceiver.sol";

contract MyERC20Token is ERC20, Ownable {
    constructor() ERC20("MyNFTToken", "MTK") Ownable(msg.sender) {
        // mint 100000 tokens to the owner
        _mint(msg.sender, 100_000 * 10 ** decimals());
    }

    // only owner can mint
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
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

    // when tokens are transferred, call the tokensReceived function on the receiver
    function _update(address from, address to, uint256 amount) internal override {
        super._update(from, to, amount);

        // if the receiver is a contract, call the tokensReceived function
        if (_isContract(to)) {
            try ITokenReceiver(to).tokensReceived(msg.sender, from, to, amount, "", "") { } catch { }
        }
    }

    // transfer and call 'tokensReceived'
    function transferAndCall(address to, uint256 amount, bytes memory data) public returns (bool) {
        bool success = transfer(to, amount);
        if (success && _isContract(to)) {
            try ITokenReceiver(to).tokensReceived(msg.sender, msg.sender, to, amount, data, "") { } catch { }
        }
        return success;
    }
}
