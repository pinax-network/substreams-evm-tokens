.PHONY: all
all:
	make build

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release
	substreams pack
	substreams graph
	substreams info

.PHONY: gui
gui:
	substreams gui substreams.yaml db_out -e eth.substreams.pinax.network:443 -s 21690730 --network eth

.PHONY: sink
sink:
	substreams-sink-sql run clickhouse://default:default@localhost:9000/default substreams.yaml -e eth.substreams.pinax.network:443 21690700:21690781 --final-blocks-only --undo-buffer-size 1000 --on-module-hash-mistmatch=warn --batch-block-flush-interval 1000 --development-mode

.PHONY: setup
setup:
	substreams-sink-sql setup clickhouse://default:default@localhost:9000/default substreams.yaml

# 21525891