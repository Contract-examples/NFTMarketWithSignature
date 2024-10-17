// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "../src/MyERC20Token.sol";

contract MyERC20TokenTest is Test {
    MyERC20Token public token;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        console2.log("owner", owner);
        user1 = address(0x1);
        console2.log("user1", user1);
        user2 = address(0x2);
        console2.log("user2", user2);
        token = new MyERC20Token();
        console2.log("token", address(token));
    }

    function testTransfer() public {
        uint256 amount = 100 * 10 ** token.decimals();

        token.transfer(user1, amount);

        assertEq(token.balanceOf(user1), amount, "Recipient balance incorrect");
        assertEq(
            token.balanceOf(address(this)), 1_000_000 * 10 ** token.decimals() - amount, "Sender balance incorrect"
        );
    }

    function testTokensReceivedHook() public {
        NFTCallbackTest receiver = new NFTCallbackTest();
        console2.log("receiver", address(receiver));

        uint256 amount = 100 * 10 ** token.decimals();

        token.transfer(user1, amount);

        vm.prank(user1);

        // test with tokenId
        uint256 tokenId = 111;
        bytes memory data = abi.encode(tokenId);
        token.transferAndCall(address(receiver), amount, data);

        assertTrue(receiver.receivedTokens());
        assertEq(receiver.lastAmount(), amount);
    }
}

// Mock contract to test NFTCallbackTest hook
contract NFTCallbackTest is IERC20Receiver {
    bool public receivedTokens;
    uint256 public lastAmount;

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
        receivedTokens = true;
        lastAmount = amount;
        console2.log("NFTCallbackTest: msg.sender", msg.sender);
        console2.log("NFTCallbackTest: from", from);
        console2.log("NFTCallbackTest: to", to);
        console2.log("NFTCallbackTest: amount", amount);

        // decode userData to get tokenId
        if (userData.length > 0) {
            uint256 tokenId = abi.decode(userData, (uint256));
            console2.log("NFTCallbackTest: tokenId", tokenId);
        } else {
            console2.log("NFTCallbackTest: no tokenId");
            return false;
        }
        return true;
    }
}
