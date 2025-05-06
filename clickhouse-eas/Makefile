.PHONY: all
all:
	make build

.PHONY: protogen
protogen:
	substreams protogen -x sf,google

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release
	substreams pack

.PHONY: gui
gui: build
	substreams gui substreams.yaml db_out -e base.substreams.pinax.network:443 -s 10000000 -t +1000 --limit-processed-blocks 0

.PHONY: dev
dev: build
	substreams-sink-sql run clickhouse://default:default@localhost:9000/eas substreams.yaml -e base.substreams.pinax.network:443 10000000:10010000 --undo-buffer-size 1 --batch-block-flush-interval 1

.PHONY: setup
setup: build
	substreams-sink-sql setup clickhouse://default:default@localhost:9000/eas substreams.yaml
