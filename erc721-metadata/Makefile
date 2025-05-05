ENDPOINT ?= eth.substreams.pinax.network:443
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SINK_RANGE := ":"

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: run
run: build
	substreams run -e $(ENDPOINT) substreams.yaml map_events -s 10000000 -t +100

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s 10000000 -t +100 --limit-processed-blocks 0

.PHONY: mints
mints: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s 10000000 -t +100

