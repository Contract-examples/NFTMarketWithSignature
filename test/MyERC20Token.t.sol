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
        user1 = address(0x1);
        user2 = address(0x2);
        token = new MyERC20Token();
    }

    function testTransfer() public {
        uint256 amount = 100 * 10 ** token.decimals();

        token.transfer(user1, amount);

        assertEq(token.balanceOf(user1), amount, "Recipient balance incorrect");
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** token.decimals() - amount, "Sender balance incorrect");
    }

    function testTokensReceivedHook() public {
        // Deploy a test contract that implements ITokenReceiver
        TokenReceiverTest receiver = new TokenReceiverTest();

        uint256 amount = 100 * 10 ** token.decimals();
        token.transfer(address(receiver), amount);

        assertTrue(receiver.receivedTokens());
        assertEq(receiver.lastAmount(), amount);
    }
}

// Mock contract to test tokensReceived hook
contract TokenReceiverTest is ITokenReceiver {
    bool public receivedTokens;
    uint256 public lastAmount;

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    )
        external
        override
    {
        receivedTokens = true;
        lastAmount = amount;
        console2.log("TokenReceiverTest: tokensReceived");
    }
}


