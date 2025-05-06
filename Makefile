.PHONY: all
all:
	make build

.PHONY: build
build:
	make pack -C ./erc721-metadata
	make pack -C ./erc1155
	make pack -C ./erc721
	make pack -C ./seaport
