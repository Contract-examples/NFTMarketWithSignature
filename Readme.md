# NFT Market with permit


## Test
```
forge test --match-test=testPermitBuy -vv
```

## Test result
```
Ran 2 tests for test/NFTMarket.t.sol:NFTMarketTest
[PASS] testPermitBuy() (gas: 310477)
Logs:
  Index: 0, Minted NFT with ID: 0
  NFT owner: seller
  Index: 0, Minted NFT with ID: 1
  NFT owner: seller2
  Index: 0, Minted NFT with ID: 2
  NFT owner: seller3
  messageHash: 0x2b7b88ac920b789994b632f390a6a22d7229d5d1b439284283056c1703df6432
  ethSignedMessageHash: 0xf8b99a7f0b51c47e2b7d597d06aeddd68cedb55eea402112a0bba8ec7d03638b
  v1: 0x1b
  r1: 0xc9f771fb1640b5868cbc09c27df8d81a08859c076d57d0d438e8df1e20412e97
  s1: 0x5e85a1e5d5c9cabdc20bf822a024b5819f86721447cdfd082741569d88a8a045
  whitelistSignature:
  0xc9f771fb1640b5868cbc09c27df8d81a08859c076d57d0d438e8df1e20412e975e85a1e5d5c9cabdc20bf822a024b5819f86721447cdfd082741569d88a8a0451b
  permitHash: 0xcc01164f54e675b22910bd2ba4e3c74a0eead6c6b787886397728191d0ac278f
  v2: 0x1c
  r2: 0x3b8e9f36db7eebca74898e68df602b7da6bcd34267794e079a07f9f7c1d8a0c2
  s2: 0x3d8ff5bba9b2807b286b8af3bce202e91337d04b78a27d8ed3061f91a56c5179

[PASS] testPermitBuyNotWhitelisted() (gas: 130592)
Logs:
  Index: 0, Minted NFT with ID: 0
  NFT owner: seller
  Index: 0, Minted NFT with ID: 1
  NFT owner: seller2
  Index: 0, Minted NFT with ID: 2
  NFT owner: seller3

Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 3.82ms (2.65ms CPU time)
```

## Deploy MyERC20Token/MyNFT
```
forge script script/DeployMyERC20PermitToken.s.sol:DeployMyERC20PermitTokenScript --rpc-url arbitrum_sepolia --broadcast --verify -vvvv
forge script script/DeployMyNFT.s.sol:DeployMyNFT --rpc-url arbitrum_sepolia --broadcast --verify -vvvv
```
## Deploy result
```
https://sepolia.arbiscan.io/address/0x6343c4a548F5f75b47Cdd1A52a52eF89bC29A5eB
MyERC20Token address: 0x6343c4a548F5f75b47Cdd1A52a52eF89bC29A5eB

https://sepolia.arbiscan.io/address/0x32eCC13478b2d03b212AE7b371F5f3C18490Bc9d
NFT address: 0x32eCC13478b2d03b212AE7b371F5f3C18490Bc9d
```

## Deploy NFTMarket
```
forge script script/DeployNFTMarket.s.sol:DeployNFTMarket --rpc-url arbitrum_sepolia --broadcast --verify -vvvv
```

## Deploy result
```
https://sepolia.arbiscan.io/address/0x98A566801FF66d156971ADa3f6D729eFBABD67Ca
NFTMarket addresas: 0x98A566801FF66d156971ADa3f6D729eFBABD67Ca
```

## Mint NFT
```
forge script script/MintMyNFT.s.sol:MintMyNFT --rpc-url arbitrum_sepolia --broadcast -vvvv
```
## Mint result
```
https://testnets.opensea.io/assets/arbitrum-sepolia/0x32ecc13478b2d03b212ae7b371f5f3c18490bc9d/0
```

## List NFT on NFT market
```
forge script script/ListNFTOnMarket.s.sol:ListNFTOnMarketScript --rpc-url arbitrum_sepolia --broadcast -vvvv
```
## result of "List NFT on NFT market"
```
txhash: https://sepolia.arbiscan.io/tx/0x493c3956855f627f850cb4083329569167e152fd558b7ecd2ac42f7f9d6a37be
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
  ----------------------------
```

## Buy NFT via whitelist on NFT market
```
forge script script/BuyNFTPermitAndQueryMarket.s.sol:BuyNFTPermitAndQueryMarketScript --rpc-url arbitrum_sepolia --broadcast -vvvv
```
## result of "Buy NFT via whitelist on NFT market"
```
== Logs ==
  NFT seller: 0x059dC4EEe9328A9f163a7e813B2f5B4A52ADD4dF
  NFT price: 100000000000000000000
  messageHash: 0xb1b91a7e381af88ceaa01975da1ce2ee2c607b1f1d0a8ef4e656d1757d992134
  ethSignedMessageHash: 0xc4bb37ae725686c50a40f856ec41f02dd9609eda1104634ca5692c8d098c04e0
  v1: 0x1b
  r1: 0x04d33c657255139993f93c79e1c667f03def67bd8aebac82e6f63bfc8b7d5d13
  s1: 0x6a3e3fb5274d1bd8dc18fb7a2f2c3a7e6054c6382cd14d2acb9f18072e5c9cd5
  whitelistSignature:
  0x04d33c657255139993f93c79e1c667f03def67bd8aebac82e6f63bfc8b7d5d136a3e3fb5274d1bd8dc18fb7a2f2c3a7e6054c6382cd14d2acb9f18072e5c9cd51b     
  permitHash: 0x43508f2e0f60ba469068601c9f387c5643a7b1b124c872f99cd605b34f5e49b6
  v2: 0x1b
  r2: 0xb3598245c7ff9a79d22ef4374a096ea5ea82a6b24df7db0ee93dab82763537c9
  s2: 0x5796dddc2e05cca0785fdf785bbf2799c745a251038763864fa4d6b367e82a5f
  NFT purchased:
  whitelistBuyer: 0xe091701aC9816D38241887147B41AE312d26e1C3
  Token ID: 0
  Price paid: 100000000000000000000

Current NFT Market status:
  ----------------------------
txhash: https://sepolia.arbiscan.io/tx/0x1b4f1d283970329d0a410b111a6c3114b55e44614e3c1e006588cc776fd812e8
opensea: https://testnets.opensea.io/assets/arbitrum-sepolia/0x0c9411984a111b26f2518e70d3731779103c9c35/0
```


