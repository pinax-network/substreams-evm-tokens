# Substreams EVM Tokens Makefile

.PHONY: all
all: build

.PHONY: build
build:
	$(MAKE) -C ens build

.PHONY: run-ens
run-ens:
	$(MAKE) -C ens run

.PHONY: resolve-ens
resolve-ens:
	@if [ -z "$(name)" ]; then \
		echo "Usage: make resolve-ens name=vitalik.eth"; \
		exit 1; \
	fi
	$(MAKE) -C ens resolve name=$(name)

.PHONY: reverse-ens
reverse-ens:
	@if [ -z "$(addr)" ]; then \
		echo "Usage: make reverse-ens addr=0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"; \
		exit 1; \
	fi
	$(MAKE) -C ens reverse addr=$(addr)

.PHONY: clean
clean:
	$(MAKE) -C ens clean
