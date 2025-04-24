.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release
	mkdir -p target/wasm32-unknown-unknown/release
	# No need to copy, we'll update substreams.yaml to point to the correct file

.PHONY: codegen
codegen:
	@echo "Using protobuf definitions from substreams-ens-pb crate"

.PHONY: package
package: build
	substreams pack ./substreams.yaml

.PHONY: run
run: build
	substreams run substreams.yaml map_events -s 3327417 -t +10000

.PHONY: resolve
resolve: build
	@if [ -z "$(name)" ]; then \
		echo "Usage: make resolve name=vitalik.eth"; \
		exit 1; \
	fi
	substreams run substreams.yaml resolve_ens_name -p "$(name)"

.PHONY: reverse
reverse: build
	@if [ -z "$(addr)" ]; then \
		echo "Usage: make reverse addr=0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"; \
		exit 1; \
	fi
	substreams run substreams.yaml reverse_resolve -p "$(addr)"

.PHONY: info
info:
	substreams info substreams.yaml

.PHONY: clean
clean:
	cargo clean
	rm -rf target/
	rm -rf src/pb/
