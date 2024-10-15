// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface INFTCallback {
    function buyNFTCallback(address from, address to, uint256 amount, bytes calldata userData) external;
}
