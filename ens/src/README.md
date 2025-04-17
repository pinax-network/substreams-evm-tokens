# ENS Substreams Source Code

This directory contains the Rust source code for the ENS Substreams module.

## Code Structure

- `lib.rs`: The main entry point for the Substreams module. It contains the implementation of the map and store modules.
- `abi/`: Generated Rust code for interacting with the ENS contracts, created by the build.rs script.

## Key Components

### Event Handlers

The `map_events` function in `lib.rs` processes Ethereum events related to ENS and converts them to structured data. It handles events from:

- ENS Registry: NewOwner, Transfer, NewResolver
- PublicResolver: AddrChanged, NameChanged
- ReverseRegistrar: ReverseClaimed

### Storage

The `store_ens_names` function in `lib.rs` stores ENS name data in a key-value store. The key is the namehash of the ENS name, and the value is an `ENSName` protobuf message containing:

- name: The human-readable name
- label: The label (for subdomains)
- node: The namehash of the parent node (for subdomains)
- owner: The owner of the name
- resolver: The resolver contract address
- addr: The Ethereum address the name resolves to
- other metadata

### Resolution Functions

- `resolve_ens_name`: Resolves an ENS name to an Ethereum address
- `reverse_resolve`: Resolves an Ethereum address to an ENS name

### Helper Functions

- `compute_namehash`: Computes the namehash of an ENS name
- `compute_reverse_node`: Computes the reverse node for an Ethereum address
- `keccak256`: Computes the keccak256 hash of data
- `get_or_create_ens_name`: Gets an existing ENS name from the store or creates a new one

## Build Process

The build process is handled by `build.rs`, which:

1. Generates Rust code from the ABI files in the `abi/` directory
2. Compiles the Rust code to WebAssembly (WASM)

The generated WASM file is used by the Substreams runtime to execute the module.
