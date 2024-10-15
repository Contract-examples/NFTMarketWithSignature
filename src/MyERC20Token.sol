// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ITokenReceiver.sol";

contract MyERC20Token is ERC20 {
    constructor() ERC20("MyNFTToken", "MTK") {
        // mint 1000 nfts to the owner
        _mint(msg.sender, 1000 * 10 ** decimals());
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
}
