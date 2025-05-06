.PHONY: deps
all:
	@echo "Building dependencies..."
	@for dir in $(shell find $(shell dirname $(CURDIR)) -type f -name "substreams.yaml" | grep -v "$(shell basename $(CURDIR))" | xargs dirname | xargs basename); do \
		echo "Building $$dir..."; \
		(cd $(shell dirname $(CURDIR))/$$dir && cargo build --target wasm32-unknown-unknown --release && substreams pack); \
	done

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release
	substreams pack

.PHONY: gui
gui: build
	substreams gui substreams.yaml db_out -e eth.substreams.pinax.network:443 -s 22211598 --network eth --production-mode

.PHONY: noop
noop: build
	substreams run substreams.yaml db_out -e eth.substreams.pinax.network:443 -s 0 -t 0 --limit-processed-blocks 0 --network eth --production-mode --noop-mode

.PHONY: dev
dev: build
	substreams-sink-sql run clickhouse://default:default@localhost:9000/tokens substreams.yaml -e eth.substreams.pinax.network:443 22211598: --final-blocks-only --undo-buffer-size 1 --on-module-hash-mistmatch=warn --batch-block-flush-interval 1

.PHONY: setup
setup: build
	substreams-sink-sql setup clickhouse://default:default@localhost:9000/tokens substreams.yaml
