# NFT Market


## Test
```
forge test --match-contract=NFTMarketTest  --fork-url arbitrum_sepolia -vv
```

## Test result
```
Ran 4 tests for test/NFTMarket.t.sol:NFTMarketTest
[PASS] testBuyNFT() (gas: 170734)
Logs:
  Index: 0, Minted NFT with ID: 0
  NFT owner: 0x0000000000000000000000000000000000000001
  Index: 0, Minted NFT with ID: 1
  NFT owner: 0x0000000000000000000000000000000000000002
  Index: 0, Minted NFT with ID: 2
  NFT owner: 0x0000000000000000000000000000000000000003
  nftContract.ownerOf(tokenId): 0x0000000000000000000000000000000000000004
  buyer: 0x0000000000000000000000000000000000000004
  paymentToken.balanceOf(seller): 200000000000000000000
  price: 200000000000000000000

[PASS] testBuyNFTCallback() (gas: 171838)
Logs:
  Index: 0, Minted NFT with ID: 0
  NFT owner: 0x0000000000000000000000000000000000000001
  Index: 0, Minted NFT with ID: 1
  NFT owner: 0x0000000000000000000000000000000000000002
  Index: 0, Minted NFT with ID: 2
  NFT owner: 0x0000000000000000000000000000000000000003
  nftContract.ownerOf(tokenId): 0x0000000000000000000000000000000000000004
  buyer: 0x0000000000000000000000000000000000000004
  paymentToken.balanceOf(seller): 100000000000000000000
  price: 100000000000000000000

[PASS] testListNFT() (gas: 294740)
Logs:
  Index: 0, Minted NFT with ID: 0
  NFT owner: 0x0000000000000000000000000000000000000001
  Index: 0, Minted NFT with ID: 1
  NFT owner: 0x0000000000000000000000000000000000000002
  Index: 0, Minted NFT with ID: 2
  NFT owner: 0x0000000000000000000000000000000000000003
  seller: listedSeller: 0x0000000000000000000000000000000000000001
  seller: listedPrice: 100000000000000000000
  seller2: listedSeller: 0x0000000000000000000000000000000000000002
  seller2: listedPrice: 100000000000000000000
  seller3: listedSeller: 0x0000000000000000000000000000000000000003
  seller3: listedPrice: 100000000000000000000

[PASS] testUnlistNFT() (gas: 82199)
Logs:
  Index: 0, Minted NFT with ID: 0
  NFT owner: 0x0000000000000000000000000000000000000001
  Index: 0, Minted NFT with ID: 1
  NFT owner: 0x0000000000000000000000000000000000000002
  NFT owner: 0x0000000000000000000000000000000000000003
  listedSeller: 0x0000000000000000000000000000000000000000
  listedPrice: 0

Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 4.82s (575.04ms CPU time)
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

