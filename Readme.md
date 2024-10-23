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
