# NFT Market


## Test
```
forge test --match-contract NFTMarketTest -vv
```

## Test result
```
Ran 4 tests for test/NFTMarket.t.sol:NFTMarketTest
[PASS] testBuyNFT() (gas: 170669)
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

[PASS] testBuyNFTCallback() (gas: 171673)
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
  Index: 0, Minted NFT with ID: 2
  NFT owner: 0x0000000000000000000000000000000000000003
  listedSeller: 0x0000000000000000000000000000000000000000
  listedPrice: 0

Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 1.84ms (1.55ms CPU time)
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
https://sepolia.arbiscan.io/address/0xeabdc6f5fc592520163729bdfae1bd891dbe9b4f
NFTMarket addresas: 0xeabdc6f5fc592520163729bdfae1bd891dbe9b4f
```

## Mint NFT
```
forge script script/MintMyNFT.s.sol:MintMyNFT --rpc-url arbitrum_sepolia --broadcast -vvvv
```
## Mint result
```
https://testnets.opensea.io/assets/arbitrum-sepolia/0x0c9411984a111b26f2518e70d3731779103c9c35/3
```

