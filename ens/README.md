# ENS Substreams

This Substreams module indexes Ethereum Name Service (ENS) data and provides functionality to resolve ENS names to Ethereum addresses and vice versa.

## Overview

The Ethereum Name Service (ENS) is a distributed, open, and extensible naming system based on the Ethereum blockchain. It maps human-readable names like 'vitalik.eth' to machine-readable identifiers such as Ethereum addresses, content hashes, and metadata.

This Substreams module:

1. Indexes ENS events from the ENS Registry, PublicResolver, and ReverseRegistrar contracts
2. Stores ENS name data including owner, resolver, address, and other metadata
3. Provides functionality to resolve ENS names to Ethereum addresses (forward resolution)
4. Provides functionality to resolve Ethereum addresses to ENS names (reverse resolution)

## Contracts Indexed

- ENS Registry: `0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e`
- PublicResolver: Various resolver contracts are supported
- ReverseRegistrar: `0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb`

## Modules

### map_events

This module maps ENS-related events from the Ethereum blockchain to structured data. It captures events such as:

- NewOwner: When a new subdomain is created
- Transfer: When ownership of a name is transferred
- NewResolver: When a name's resolver is changed
- AddrChanged: When a name's address is updated
- NameChanged: When a name's reverse record is updated

### store_ens_names

This module stores ENS name data in a key-value store, where the key is the namehash of the ENS name and the value is the ENS name data.

### resolve_ens_name

This module resolves an ENS name to an Ethereum address. It takes an ENS name as input (e.g., "vitalik.eth") and returns the corresponding Ethereum address.

### reverse_resolve

This module resolves an Ethereum address to an ENS name. It takes an Ethereum address as input (e.g., "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045") and returns the corresponding ENS name.

## Usage

### Forward Resolution (ENS name to Ethereum address)

```bash
substreams run substreams.yaml resolve_ens_name -p "vitalik.eth"
```

### Reverse Resolution (Ethereum address to ENS name)

```bash
substreams run substreams.yaml reverse_resolve -p "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
```

## Building

```bash
cargo build --target wasm32-unknown-unknown --release
```

## Testing

```bash
substreams run substreams.yaml map_events -s 3327417 -t +10000
```

## License

[Apache 2.0](LICENSE)
