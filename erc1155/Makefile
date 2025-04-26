ENDPOINT ?= eth.substreams.pinax.network:443
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SINK_RANGE := ":"

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: protogen
protogen:
	substreams protogen ./substreams.yaml --exclude-paths="sf/substreams,google"

.PHONY: pack
pack: build
	substreams pack -o erc1155.spkg ./substreams.yaml

.PHONY: run
run: build
	substreams run -e $(ENDPOINT) substreams.yaml map_events -s 10000000 -t +100

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s 10000000 -t +100 --limit-processed-blocks 0

.PHONY: mints
mints: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_mints -s 10000000 -t +100


.PHONY: db_out
db_out: build
	substreams gui -e $(ENDPOINT) substreams.yaml db_out -s 10000000 -t +100

