ENDPOINT ?= eth.substreams.pinax.network:443
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
SINK_RANGE := ":"

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml db_out -s 10000000

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) substreams.yaml db_out -H "X-Sf-Substreams-Parallel-Jobs: 600"

.PHONY: dev
dev:
	substreams-sink-sql run clickhouse://default:default@localhost:9000/default substreams.yaml -e $(ENDPOINT) 22211598: --final-blocks-only --undo-buffer-size 1 --on-module-hash-mistmatch=warn --batch-block-flush-interval 1 --development-mode

.PHONY: setup
setup: pack
	substreams-sink-sql setup clickhouse://default:default@localhost:9000/default substreams.yaml
