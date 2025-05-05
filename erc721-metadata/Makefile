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
	substreams run -e $(ENDPOINT) substreams.yaml map_events -s 0 -t 0 --limit-processed-blocks 0 --production-mode --noop-mode

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s 20000000 -t +100 --limit-processed-blocks 0
