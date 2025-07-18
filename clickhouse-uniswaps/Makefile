ENDPOINT ?= arbone.substreams.pinax.network:443
START_BLOCK ?= 358855435
PARALLEL_JOBS ?= 500

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) substreams.yaml db_out -H "X-Sf-Substreams-Parallel-Jobs: $(PARALLEL_JOBS)" $(START_BLOCK):

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml db_out -s $(START_BLOCK) --network eth

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml db_out -s $(START_BLOCK) -t 0 --limit-processed-blocks 0 --production-mode  -H "X-Sf-Substreams-Parallel-Jobs: $(PARALLEL_JOBS)"

.PHONY: dev
dev: build
	substreams-sink-sql run clickhouse://default:default@localhost:9000/default substreams.yaml -e $(ENDPOINT) $(START_BLOCK): --undo-buffer-size 100 --on-module-hash-mistmatch=warn --batch-block-flush-interval 100 --infinite-retry --development-mode

.PHONY: setup
setup: pack
	substreams-sink-sql setup clickhouse://default:default@localhost:9000/default substreams.yaml