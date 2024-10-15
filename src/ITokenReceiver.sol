// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// this is our interface for the tokensReceived function
interface ITokenReceiver {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData
    )
        external;
}
