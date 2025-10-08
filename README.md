# EVM `Substreams`

> Ethereum, Base, BSC, Polygon, ArbitrumOne, Optimism, etc..

## Substreams Packages

- [x] ERC-20
  - [x] Balances & Transfers
  - [x] Supply
  - [x] Contract Metadata
- [x] Native (ETH)
  - [x] Balances & Transfers
- [x] Uniswap (V2, V3 & V4)
- [x] ENS Reverse Resolution
- [x] NFTs (ERC-721 & ERC-1155)
  - [x] Transfers
  - [x] Contract Metadata
- [x] Seaport

## Supported DEXes and AMMs

### Full Support of DEX protocol

> Includes `amm_pool` field
>
> Swaps are being reported via **Swap** programs
>
> Ordered by most transactions (only includes DEX with >100K Swaps in 2025)

| DEX Name | Protocol        | Factory Address |
|----------|-----------------|-----------------|

## ETH

> Ordered by most transactions (only includes DEX with >10K Swaps in 2025)

| DEX                   | Protocol   | Factory Address                            |
| --------------------- | ---------- | ------------------------------------------ |
| Uniswap V2            | uniswap_v2 | 0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f |
| Uniswap V3            | uniswap_v3 | 0x1f98431c8ad98523631ae4a59f267346ea31f984 |
| Uniswap V4            | uniswap_v4 | 0x000000000004444c5dc75cb358380d2e3de08a90 |
| SushiSwap V2          | uniswap_v2 | 0xc0aee478e3658e2610c5f7a4a2e1777ce9e4f2ac |
| Ring Swap             | uniswap_v2 | 0xeb2a625b704d73e82946d8d026e1f588eed06416 |
| Shiba Inu             | uniswap_v2 | 0x115934131916c8b277dd010ee02de363c09d037c |
| Crypto.com: DeFi Swap | uniswap_v2 | 0x9deb29c9a4c7a88a3c0257393b7f3335338d9a9d |
| PancakeSwap V2        | uniswap_v2 | 0x1097053fd2ea711dad45caccc45eff7548fcb362 |
| Uniswap V2            | uniswap_v2 | 0xb8900621b03892c2d030e05cb9e01f6474814f6a |
| Solidly V3            | uniswap_v3 | 0x70fe4a44ea505cfa3a57b95cf2862d4fd5f0f687 |
| SushiSwap V3          | uniswap_v3 | 0xbaceb8ec6b9355dfc0269c18bac9d6e2bdc29c4f |
| Fraxswap V2           | uniswap_v2 | 0x43ec799eadd63848443e2347c49f5f52e8fe0f6f |
| Verse Exchange        | uniswap_v2 | 0xee3e9e46e34a27dc755a63e2849c9913ee1a06e2 |
| Integral              | uniswap_v2 | 0xc480b33ee5229de3fbdfad1d2dcd3f3bad0c56c6 |
| Shiba Inu             | uniswap_v3 | 0xd9ce49caf7299daf18fffcb2b84a44fd33412509 |
| NineInch              | uniswap_v2 | 0xcbae5c3f8259181eb7e2309bc4c72fdf02dd56d8 |
| Orion                 | uniswap_v2 | 0x5fa0060fcfea35b31f7a5f6025f0ff399b98edf1 |
| Future Lithium        | uniswap_v2 | 0x4eef5746ed22a2fd368629c1852365bf5dcb79f1 |
| Neopin                | uniswap_v2 | 0x2d723f60ad8da76286b2ac120498a5ea6babc792 |
| DelioSwap             | uniswap_v2 | 0xa206f6274b178b5090f64f39ca49878955d93756 |
| KwikSwap              | uniswap_v2 | 0xdd9efcbdf9f422e2fc159efe77add3730d48056d |
| SakeSwap              | uniswap_v2 | 0x75e48c954594d64ef9613aeef97ad85370f13807 |
| Nova                  | uniswap_v2 | 0xfe87e130e2b13d842c4ca99f6e6567712f97c64d |
| LinkSwap              | uniswap_v2 | 0x696708db871b77355d6c2be7290b27cf0bb9b24b |
| EtherVista            | uniswap_v2 | 0x9a27cb5ae0b2cee0bb71f9a85c0d60f3920757b4 |
| DooarSwap             | uniswap_v2 | 0x1e895bfe59e3a5103e8b7da3897d1f2391476f3c |

## Arbitrum One

| DEX          | Protocol   | Factory Address                            |
| ------------ | ---------- | ------------------------------------------ |
| Uniswap V3   | uniswap_v3 | 0x1f98431c8ad98523631ae4a59f267346ea31f984 |
| Uniswap V4   | uniswap_v4 | 0x360e68faccca8ca495c1b759fd9eee466db9fb32 |
| SushiSwap V3 | uniswap_v3 | 0x1af415a1eba07a4986a52b6f2e7de7003d82231e |
| Ramses       | uniswap_v3 | 0xaa2cd7477c451e703f3b9ba5663334914763edf8 |
| SushiSwap V2 | uniswap_v2 | 0xc35dadb65012ec5796536bd9864ed8773abc74c4 |
| Uniswap V2   | uniswap_v2 | 0xf1d7cc64fb4452f05c498126312ebe29f30fbcf9 |
| Camelot      | uniswap_v2 | 0x6eccab422d763ac031210895c81787e87b43a652 |
| Camelot      | uniswap_v2 | 0x16ed649675e6ed9f1480091123409b4b8d228dc1 |
| GammaSwap    | uniswap_v2 | 0xcb85e1222f715a81b8edaeb73b28182fa37cffa8 |
| Solidly V3   | uniswap_v3 | 0x70fe4a44ea505cfa3a57b95cf2862d4fd5f0f687 |
| Uniswap V2   | uniswap_v2 | 0x9b43e504d84adcb7321dc2551a86bff1084ae2e5 |
| Arbswap      | uniswap_v2 | 0xd394e9cc20f43d2651293756f8d320668e850f1b |
| UpSwap       | uniswap_v2 | 0xc8b66e63976670d25feeaad28fe317212766d823 |
| SpartaDex    | uniswap_v2 | 0xfe8ec10fe07a6a6f4a2584f8cd9fe232930eaf55 |
| PancakeSwap  | uniswap_v2 | 0x02a84c1b3bbd7401a5f7fa98a384ebc70bb5749e |
| DXswap       | uniswap_v2 | 0x359f20ad0f42d75a5077e65f30274cabe6f4f01a |
| Arbidex      | uniswap_v2 | 0x1c6e968f2e6c9dec61db874e28589fd5ce3e1f2c |
| Integral     | uniswap_v2 | 0x717ef162cf831db83c51134734a15d1ebe9e516a |
| Trader Joe   | uniswap_v2 | 0xae4ec9901c3076d0ddbe76a520f9e90a6227acb7 |

## Polygon

| DEX             | Protocol   | Factory Address                            |
| --------------- | ---------- | ------------------------------------------ |
| Uniswap V3      | uniswap_v3 | 0x1f98431c8ad98523631ae4a59f267346ea31f984 |
| Quickswap V2    | uniswap_v2 | 0x5757371414417b8c6caad45baef941abc7d3ab32 |
| Uniswap V4      | uniswap_v4 | 0x67366782805870060151383f4bbff9dab53e5cd6 |
| SushiSwap V2    | uniswap_v2 | 0xc35dadb65012ec5796536bd9864ed8773abc74c4 |
| Uniswap V2      | uniswap_v2 | 0x9e5a52f57b3038f1b8eee45f28b3c1967e22799c |
| Stabl.fi        | uniswap_v3 | 0x91e1b99072f238352f59e58de875691e20dc19c1 |
| SushiSwap V3    | uniswap_v3 | 0x917933899c6a5f8e37f31e19f92cdbff7e8ff0e2 |
| ApeSwap V2      | uniswap_v2 | 0xcf083be4164828f00cae704ec15a36d711491284 |
| SweepnFlip      | uniswap_v2 | 0x16ed649675e6ed9f1480091123409b4b8d228dc1 |
| DFYN            | uniswap_v2 | 0xe7fb3e833efe5f9c441105eb65ef8b261266423b |
| Jetswap         | uniswap_v2 | 0x668ad0ed2622c62e24f0d5ab6b6ac1b9d2cd4ac7 |
| DooarSwap       | uniswap_v2 | 0xbdd46fd173ad1d158578feb5d10573baf8ee89d2 |
| Polycat Finance | uniswap_v2 | 0x477ce834ae6b7ab003cce4bc4d8697763ff456fa |
| Wault Finance   | uniswap_v2 | 0xa98ea6356a316b44bf710d5f9b6b4ea0081409ef |
| Elk             | uniswap_v2 | 0xe3bd06c7ac7e1ceb17bdd2e5ba83e40d1515af2a |

## Unichain

| DEX        | Protocol   | Factory Address                            |
| ---------- | ---------- | ------------------------------------------ |
| Uniswap V4 | uniswap_v4 | 0x1f98400000000000000000000000000000000004 |
| Uniswap V3 | uniswap_v3 | 0x1f98400000000000000000000000000000000003 |
| Uniswap V2 | uniswap_v2 | 0x1f98400000000000000000000000000000000002 |

## BSC

| DEX            | Protocol   | Factory Address                            |
| -------------- | ---------- | ------------------------------------------ |
| PancakeSwap V2 | uniswap_v2 | 0xca143ce32fe78f1f7019d7d551a6402fc5350c73 |
| PancakeSwap V3 | uniswap_v3 | 0xdb1d10011ad0ff90774d0c6bb92e5c5c8b4461f7 |
| PancakeSwap V4 | uniswap_v4 | 0x28e2ea090877bf75740558f6bfb36a5ffee9e9df |
| BakerySwap     | uniswap_v2 | 0xbcfccbde45ce874adcb698cc183debcf17952812 |
| Biswap         | uniswap_v2 | 0x858e3312ed3a876947ea49d572a7c42de08af7ee |
| ApeSwap V2     | uniswap_v2 | 0x0841bd0b734e4f5853f0dd8d7ea041c241fb0da6 |
| MDEX (BSC)     | uniswap_v2 | 0x9a272d734c5a0d7d84e0a892e891a553e8066dce |
| WaultSwap      | uniswap_v2 | 0x86407bea2078ea5f5eb5a52b2caa963bc1f889da |
| Babyswap       | uniswap_v2 | 0xc6b7ee49d386bae4fd501f2d2f8d18828f1f6285 |
| Jetswap        | uniswap_v2 | 0xd6715a8be3944ec72738f0bfdc739d48c3c29349 |
| JulSwap        | uniswap_v2 | 0x3cd1c46068daea5ebb0d3f55f6915b10648062b8 |

## Optimism

| DEX          | Protocol   | Factory Address                            |
| ------------ | ---------- | ------------------------------------------ |
| Uniswap V3   | uniswap_v3 | 0x1f98431c8ad98523631ae4a59f267346ea31f984 |
| Uniswap V4   | uniswap_v4 | 0x9a13f98cb987694c9f086b1f5eb990eea8264ec3 |
| Velodrome V3 | uniswap_v3 | 0x70fe4a44ea505cfa3a57b95cf2862d4fd5f0f687 |
| Velodrome V2 | uniswap_v2 | 0x0c3c1c532f1e39edf36be9fe0be1410313e074bf |
| Curve        | uniswap_v3 | 0x9c6522117e2ed1fe5bdb72bb0ed5e3f2bde7dbe0 |
| Beethoven X  | uniswap_v2 | 0x7962223d940e1b099abae8f54cabfb8a3a0887ab |

## Avalanche

| DEX                    | Protocol   | Factory Address                            |
| ---------------------- | ---------- | ------------------------------------------ |
| Trader Joe V2.1        | uniswap_v2 | 0x9ad6c38be94206ca50bb0d90783181662f0cfa10 |
| Trader Joe V3          | uniswap_v3 | 0x740b1c1de25031c31ff4fc9a62f554a55cdc1bad |
| Trader Joe V2          | uniswap_v3 | 0xaaa32926fce6be95ea2c51cb4fcb60836d320c42 |
| Pangolin V2            | uniswap_v2 | 0xf16784dcaf838a3e16bef7711a62d12413c39bd1 |
| Pangolin V1            | uniswap_v2 | 0xefa94de7a4656d787667c749f7e1223d71e9fd88 |
| Elk Finance            | uniswap_v3 | 0x1128f23d0bc0a8396e9fbc3c0c68f5ea228b8256 |
| Uniswap V4 (Avalanche) | uniswap_v4 | 0x06380c0e0912312b5150364b9dc4542ba0dbbc85 |
| Lydia Finance          | uniswap_v2 | 0x26b42c208d8a9d8737a2e5c9c57f4481484d4616 |
| SushiSwap V2           | uniswap_v2 | 0xc35dadb65012ec5796536bd9864ed8773abc74c4 |
| OliveSwap              | uniswap_v2 | 0x1051e74c859cc1e662c3afa3f170103522a2e70f |

## Base

| DEX           | Protocol    | Factory Address                            |
| ------------- | ----------- | ------------------------------------------ |
| Uniswap V3    | uniswap_v3  | 0x33128a8fc17869897dce68ed026d694621f6fdfd |
| Uniswap V2    | uniswap_v2  | 0x8909dc15e40173ff4699343b6eb8132c65e18ec6 |
| Uniswap V4    | uniswap_v4  | 0x498581ff718922c3f8e6a244956af099b2652b2b |
| SushiSwap V2  | uniswap_v3  | 0xc35dadb65012ec5796536bd9864ed8773abc74c4 |
| BaseSwap      | uniswap_v3  | 0x38015d05f4fec8afe15d7cc0386a126574e8077b |
| Alien Base V3 | uniswap_v3  | 0x0fd83557b2be93617c9c1c1b6fd549401c74558c |
| BaseSwap V2   | uniswap_v2  | 0xfda619b6d20975be80a10332cd39b9a4b0faa8bb |
| Solidly V3    | uniswap_v3  | 0x70fe4a44ea505cfa3a57b95cf2862d4fd5f0f687 |
| Alien Base V2 | uniswap_v2  | 0x3e84d913803b02a4a7f027165e8ca42c14c0fde7 |
