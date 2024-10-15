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


## Deploy MyERC20Token
```
forge script script/DeployMyERC20Token.s.sol:DeployMyERC20TokenScript --rpc-url arbitrum_sepolia --broadcast --verify -vvvv
```
## Deploy result
```
MyERC20Token address: https://sepolia.arbiscan.io/address/0x0f5011654af81e582bf7358c16515f18a0cbbbc9
```


