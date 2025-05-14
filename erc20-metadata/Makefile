ENDPOINT ?= eth.substreams.pinax.network:443
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SINK_RANGE := ":"

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) https://github.com/pinax-network/substreams-evm-tokens/releases/download/tokens-v0.1.0/evm-erc20-metadata-v0.1.0.spkg map_events -H "X-Sf-Substreams-Parallel-Jobs: 600"

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s 21469410

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s 0 -t 0 --limit-processed-blocks 0 --production-mode