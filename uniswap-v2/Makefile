ENDPOINT ?= eth.substreams.pinax.network:443
START_BLOCK ?= 12205119

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) https://github.com/pinax-network/substreams-evm-tokens/releases/download/uniswaps-v0.1.0/evm-uniswap-v2-v0.1.0.spkg map_events -H "X-Sf-Substreams-Parallel-Jobs: 500"

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s $(START_BLOCK)

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) https://github.com/pinax-network/substreams-evm-tokens/releases/download/uniswaps-v0.1.0/evm-uniswap-v2-v0.1.0.spkg map_events -s 0 -t 0 --limit-processed-blocks 0 --production-mode