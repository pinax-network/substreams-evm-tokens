ENDPOINT ?= eth.substreams.pinax.network:443
START_BLOCK ?= 23142793

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) https://github.com/pinax-network/substreams-evm-tokens/releases/download/erc20-balances-v0.1.1/evm-erc20-balances-rpc-v0.1.1.spkg map_events -H "X-Sf-Substreams-Parallel-Jobs: 600"

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s $(START_BLOCK)

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s $(START_BLOCK) --production-mode