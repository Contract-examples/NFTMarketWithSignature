# NFT Market


## Test
```
forge test --match-contract=NFTMarketTest
forge test --match-contract=NFTMarketInvariantTest
forge test --match-contract=NFTMarketTest --fork-url arbitrum_sepolia
```

## Test result

### NFTMarketTest
```
Ran 20 tests for test/NFTMarket.t.sol:NFTMarketTest
[PASS] testBuyNFT() (gas: 194007)
[PASS] testBuyNFTCallback() (gas: 195126)
[PASS] testBuyNFTCallbackInsufficientPayment() (gas: 112667)
[PASS] testBuyNFTCallbackPaidMoreThanPrice() (gas: 178592)
[PASS] testBuyNFTCallbackTokensReceivedFailed() (gas: 139444)
[PASS] testBuyNFTEmitEvent() (gas: 167693)
[PASS] testBuyNFTInsufficientBalance() (gas: 136452)
[PASS] testBuyNFTNotListed() (gas: 48837)
[PASS] testBuyNFTRepeat() (gas: 166521)
[PASS] testBuyNFTheSenderIsTheSeller() (gas: 129804)
[PASS] testFuzzListAndBuyNFT(uint256,uint256) (runs: 1000, μ: 259971, ~: 259989)
[PASS] testListEmitEvent() (gas: 105162)
[PASS] testListNFT() (gas: 345205)
[PASS] testListNFTNotApproved() (gas: 31231)
[PASS] testListNFTZeroPrice() (gas: 51262)
[PASS] testListNotOwner() (gas: 74295)
[PASS] testNoTokenBalanceInMarket() (gas: 315712)
[PASS] testUnlistNFT() (gas: 95280)
[PASS] testUnlistNFTEmitEvent() (gas: 81410)
[PASS] testUnlistNFTNotTheSeller() (gas: 126223)
Suite result: ok. 20 passed; 0 failed; 0 skipped; finished in 448.04ms (456.30ms CPU time)

Ran 1 test suite in 452.17ms (448.04ms CPU time): 20 tests passed, 0 failed, 0 skipped (20 total tests)
```

### NFTMarketInvariantTest
```
Ran 3 tests for test/NFTMarket.t.sol:NFTMarketInvariantTest
[PASS] invariant_listingsAreValid() (runs: 256, calls: 128000, reverts: 128000)
[PASS] invariant_marketHasNoBalance() (runs: 256, calls: 128000, reverts: 128000)
[PASS] invariant_nftOwnersHaveCorrectBalance() (runs: 256, calls: 128000, reverts: 128000)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 3.45s (10.23s CPU time)

Ran 1 test suite in 3.45s (3.45s CPU time): 3 tests passed, 0 failed, 0 skipped (3 total tests)
```

## Deploy MyERC20Token/MyNFT
```
forge script script/DeployMyERC20Token.s.sol:DeployMyERC20TokenScript --rpc-url arbitrum_sepolia --broadcast --verify -vvvv
forge script script/DeployMyNFT.s.sol:DeployMyNFT --rpc-url arbitrum_sepolia --broadcast --verify -vvvv
```
## Deploy result
```
https://sepolia.arbiscan.io/address/0x54f0bcb385f758e38ebb3e5085abab3db1cf3153
MyERC20Token address: 0x54f0bcb385f758e38ebb3e5085abab3db1cf3153

https://sepolia.arbiscan.io/address/0x0C9411984a111B26F2518e70D3731779103c9c35
NFT address: 0x0C9411984a111B26F2518e70D3731779103c9c35
```

## Deploy NFTMarket
```
forge script script/DeployNFTMarket.s.sol:DeployNFTMarket --rpc-url arbitrum_sepolia --broadcast --verify -vvvv
```

## Deploy result
```
https://sepolia.arbiscan.io/address/0xEaBDC6F5FC592520163729bDFAe1bD891DbE9b4F
NFTMarket addresas: 0xEaBDC6F5FC592520163729bDFAe1bD891DbE9b4F
```

## Mint NFT
```
forge script script/MintMyNFT.s.sol:MintMyNFT --rpc-url arbitrum_sepolia --broadcast -vvvv
```
## Mint result
```
https://testnets.opensea.io/assets/arbitrum-sepolia/0x0c9411984a111b26f2518e70d3731779103c9c35/3
```

## List NFT on NFT market
```
forge script script/ListNFTOnMarket.s.sol:ListNFTOnMarketScript --rpc-url arbitrum_sepolia --broadcast -vvvv
```
## result of "List NFT on NFT market"
```
txhash: https://sepolia.arbiscan.io/tx/0x42a323eb877e31f69e79caa80159bb858605efe1d592cb78e10e713d4656e444
```

## Query NFT market
```
forge script script/QueryNFTMarket.s.sol:QueryNFTMarketScript --rpc-url arbitrum_sepolia --broadcast -vvvv
```
## result of "Query NFT market"
```
== Logs ==
  NFTs listed on the market:
  ----------------------------
  Token ID: 0
  Price: 100000000000000000000
  Seller: 0x059dC4EEe9328A9f163a7e813B2f5B4A52ADD4dF
  Current Owner: 0x059dC4EEe9328A9f163a7e813B2f5B4A52ADD4dF
```

## Buy NFT on NFT market
```
forge script script/BuyNFTAndQueryMarket.s.sol:BuyNFTAndQueryMarketScript --rpc-url arbitrum_sepolia --broadcast -vvvv
```
## result of "Buy NFT on NFT market"
```
== Logs ==
  NFT seller: 0x059dC4EEe9328A9f163a7e813B2f5B4A52ADD4dF
  NFT price: 100000000000000000000
  NFT purchased:
  Buyer: 0xe091701aC9816D38241887147B41AE312d26e1C3
  Token ID: 0
  Price paid: 100000000000000000000
Current NFT Market status:
  ----------------------------
txhash: https://sepolia.arbiscan.io/tx/0x1b4f1d283970329d0a410b111a6c3114b55e44614e3c1e006588cc776fd812e8
opensea: https://testnets.opensea.io/assets/arbitrum-sepolia/0x0c9411984a111b26f2518e70d3731779103c9c35/0
```

