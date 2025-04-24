# EVM-Tokens: `Substreams`

`ERC-20` & `Native` tokens for EVM blockchains.

> Ethereum, Base, BSC, Polygon, ArbitrumOne, Optimism, etc..

## Supported by Sinks

- [x] [Substreams: File Sink](https://github.com/streamingfast/substreams-sink-files) - Apache Parquet (Protobuf Map modules)
- [x] [Substreams: SQL Sink](https://github.com/streamingfast/substreams-sink-sql) - Clickhouse / ~~PostgreSQL~~

## Substreams Packages

- [x] ERC-20 Balances & Transfers
- [x] Native Balances & Transfers
- [x] ERC-20 Contract Metadata
- [x] EVM Token Prices
  - [x] Uniswap V2 factories
- [x] ERC-20 Circulating Supply
- [x] ENS Reverse Resolution

## Substreams Graph

```mermaid
graph TD;
  Block[source: sf.ethereum.type.v2.Block]

  Block --> erc20[erc20 + RPC] --> db_out;
  Block --> native --> db_out;
  Block --> contracts[contracts + RPC] --> db_out;
  Block --> prices --> db_out;
  Block --> ens[ENS] --> db_out_ens;
```
