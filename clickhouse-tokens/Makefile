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
	substreams-sink-noop $(ENDPOINT) substreams.yaml db_out -H "X-Sf-Substreams-Parallel-Jobs: 500"

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml db_out -s 0 --production-mode

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml db_out -s 0 -t 0 --limit-processed-blocks 0 --production-mode

.PHONY: dev
dev: build
	substreams-sink-sql run clickhouse://default:default@localhost:9000/default substreams.yaml -e $(ENDPOINT) 0: --final-blocks-only --undo-buffer-size 1 --on-module-hash-mistmatch=warn --batch-block-flush-interval 1 --infinite-retry

.PHONY: setup
setup: pack
	substreams-sink-sql setup clickhouse://default:default@localhost:9000/default substreams.yaml
