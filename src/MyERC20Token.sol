// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ITokenReceiver.sol";

contract MyERC20Token is ERC20 {
    constructor() ERC20("MyNFTToken", "MTK") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    function _isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
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
