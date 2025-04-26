.PHONY: all
all:
	make build

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release
	substreams pack ./erc20-balances
	substreams pack ./erc20-balances-rpc
	substreams pack ./erc20-contracts
	substreams pack ./erc20-contracts-rpc
	substreams pack ./native-balances
	substreams pack ./native-contracts
	substreams pack ./uniswap-v2
	substreams pack ./uniswap-v3
	substreams pack ./clickhouse
	substreams pack ./ens
