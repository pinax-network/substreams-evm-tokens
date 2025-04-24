# Testing the ENS Substreams Module

This document provides instructions for testing the ENS Substreams module.

## Prerequisites

- [Latest Substreams CLI](https://substreams.streamingfast.io/getting-started/installing-the-cli) - Make sure to install the latest version
- Access to an Ethereum RPC endpoint (e.g., Infura, Alchemy, or a local node)

## Recommended Testing Method: Substreams GUI

For a more visual testing experience, it's recommended to use the `substreams gui` command instead of the regular `substreams run` command. The GUI provides a better visualization of the data flow and makes it easier to debug issues.

```bash
# Example of using the GUI for testing the map_events module
substreams gui substreams.yaml map_events \
  -e mainnet.eth.streamingfast.io:443 \
  --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
  -s 3327417 \
  --stop-block +1000
```

This will open a web interface in your browser where you can see the module execution in real-time, with visual representations of the data flow and module outputs.

> **Note:** Replace the endpoint and API key with your own if needed. The example uses StreamingFast's public endpoint.

## Building the Substreams

Before testing, you need to build the Substreams package:

```bash
cd ens
make build
```

This will compile the Rust code and package it into a `.spkg` file.

### Troubleshooting WASM Build Issues

If you encounter a "bad magic number" error when running the substreams, it indicates that your WASM file might be corrupted or not a valid WebAssembly module. Follow these steps to fix it:

1. **Rebuild your WASM file**:
   ```bash
   cargo build --release --target wasm32-unknown-unknown
   ```

2. **Verify the WASM file**:
   ```bash
   # Check if the file exists
   ls -la target/wasm32-unknown-unknown/release/substreams.wasm
   
   # Examine the file header
   hexdump -n 16 target/wasm32-unknown-unknown/release/substreams.wasm
   ```
   
   The hexdump should start with: `00 61 73 6d` (the WebAssembly magic bytes)

3. **Update your substreams.yaml if needed**:
   Make sure the path in your `binaries` section points to the correct WASM file.

4. **Try running with production mode using the GUI**:
   ```bash
   substreams gui substreams.yaml map_events \
     --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
     -e mainnet.eth.streamingfast.io:443 \
     -s 18000000 \
     --stop-block +10 \
     --production-mode
   ```

## Testing the map_events Module

To test the `map_events` module, which extracts ENS events from Ethereum blocks:

```bash
substreams gui substreams.yaml map_events \
  -e mainnet.eth.streamingfast.io:443 \
  --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
  -s 3327417 \
  --stop-block +1000
```

This will open a web interface showing the ENS events found in 1000 blocks starting from block 3327417 (the ENS Registry deployment block).

## Testing the resolve_ens_name Module

To test the `resolve_ens_name` module, which resolves an ENS name to an Ethereum address:

```bash
substreams gui substreams.yaml resolve_ens_name \
  -e mainnet.eth.streamingfast.io:443 \
  --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
  -s 16000000 \
  --limit-processed-blocks 200000 \
  -p "resolve_ens_name=vitalik.eth"
```

This should display the Ethereum address associated with "vitalik.eth" in the GUI.

## Testing the reverse_resolve Module

To test the `reverse_resolve` module, which resolves an Ethereum address to an ENS name:

```bash
substreams gui substreams.yaml reverse_resolve \
  -e mainnet.eth.streamingfast.io:443 \
  --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
  -s 16000000 \
  --limit-processed-blocks 200000 \
  -p "reverse_resolve=0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
```

This should return the ENS name associated with the given Ethereum address (e.g., "vitalik.eth").

## Testing with Clickhouse

To test the Clickhouse integration:

1. Make sure you have a Clickhouse instance running.
2. Create the ENS tables using the schema in `clickhouse/schema.ens.sql`.
3. Run the Substreams with the SQL sink:

```bash
# First, visualize the data flow with the GUI
substreams gui clickhouse/substreams.yaml db_out_ens \
  -e mainnet.eth.streamingfast.io:443 \
  --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
  -s 3327417 \
  --stop-block +1000

# Then, when ready to populate the database
substreams run clickhouse/substreams.yaml db_out_ens \
  -e mainnet.eth.streamingfast.io:443 \
  --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
  -s 3327417 \
  --stop-block +1000 \
  | substreams-sink-sql run \
    --engine clickhouse \
    --dsn "clickhouse://default:password@localhost:9000/default" \
    --schema-file clickhouse/schema.ens.sql
```

> **Note:** Replace the Clickhouse connection details with your own. The example uses default local Clickhouse settings.

4. Query the Clickhouse database to verify the data:

```sql
SELECT * FROM ens_names LIMIT 10;
```

## Verifying Specific Examples

To verify the specific examples mentioned in the task:

1. Check if "vitalik.eth" resolves to the correct address:

```bash
substreams gui substreams.yaml resolve_ens_name \
  -e mainnet.eth.streamingfast.io:443 \
  --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
  -s 16000000 \
  --limit-processed-blocks 20000000 \
  -p "resolve_ens_name=vitalik.eth"
```

Expected output in GUI: `0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045`

2. Check if the address resolves back to "vitalik.eth":

```bash
substreams gui substreams.yaml reverse_resolve \
  -e mainnet.eth.streamingfast.io:443 \
  --header "x-api-key: server_eb7fdcb8df98511f3f49671be6e0d2f4" \
  -s 16000000 \
  --limit-processed-blocks 20000000 \
  -p "reverse_resolve=0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
```

Expected output: `vitalik.eth`

## Alternative Testing Methods

If you're having trouble running the substreams locally due to processing limitations, you can use these alternative methods to verify ENS resolution functionality:

### Using Web3.js with Direct JSON-RPC Calls

You can use web3.js to directly call the ENS resolver contracts:

```javascript
// ens-web3-test.js
const Web3 = require('web3');

// ENS Registry and Resolver ABIs (simplified for this example)
const ENS_REGISTRY_ABI = [
  {
    "constant": true,
    "inputs": [{"name": "node", "type": "bytes32"}],
    "name": "resolver",
    "outputs": [{"name": "", "type": "address"}],
    "type": "function"
  }
];

const ENS_RESOLVER_ABI = [
  {
    "constant": true,
    "inputs": [{"name": "node", "type": "bytes32"}],
    "name": "addr",
    "outputs": [{"name": "", "type": "address"}],
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [{"name": "node", "type": "bytes32"}],
    "name": "name",
    "outputs": [{"name": "", "type": "string"}],
    "type": "function"
  }
];

// ENS Registry address on Ethereum mainnet
const ENS_REGISTRY_ADDRESS = '0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e';

// Namehash function to convert ENS names to node hashes
function namehash(name) {
  let node = '0x0000000000000000000000000000000000000000000000000000000000000000';
  if (name) {
    const labels = name.split('.');
    for (let i = labels.length - 1; i >= 0; i--) {
      const labelHash = Web3.utils.keccak256(labels[i]);
      node = Web3.utils.keccak256(node + labelHash.slice(2));
    }
  }
  return node;
}

// Reverse namehash for address to name resolution
function reverseNamehash(address) {
  return namehash(address.slice(2).toLowerCase() + '.addr.reverse');
}

async function testENS() {
  // Connect to Ethereum mainnet
  const web3 = new Web3('https://mainnet.infura.io/v3/YOUR_INFURA_KEY');
  
  // Create ENS Registry contract instance
  const ensRegistry = new web3.eth.Contract(ENS_REGISTRY_ABI, ENS_REGISTRY_ADDRESS);
  
  // Forward resolution: ENS name to address
  const nameNode = namehash('vitalik.eth');
  const resolverAddress = await ensRegistry.methods.resolver(nameNode).call();
  
  if (resolverAddress !== '0x0000000000000000000000000000000000000000') {
    const resolver = new web3.eth.Contract(ENS_RESOLVER_ABI, resolverAddress);
    const address = await resolver.methods.addr(nameNode).call();
    console.log('Address for vitalik.eth:', address);
  }
  
  // Reverse resolution: address to ENS name
  const reverseNode = reverseNamehash('0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045');
  const reverseResolverAddress = await ensRegistry.methods.resolver(reverseNode).call();
  
  if (reverseResolverAddress !== '0x0000000000000000000000000000000000000000') {
    const reverseResolver = new web3.eth.Contract(ENS_RESOLVER_ABI, reverseResolverAddress);
    const name = await reverseResolver.methods.name(reverseNode).call();
    console.log('Name for 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045:', name);
  }
}

testENS().catch(console.error);
```

Run with:
```bash
npm install web3
node ens-web3-test.js
```

### Using Ethers.js (Simpler Approach)

Ethers.js provides a simpler interface for ENS resolution:

```javascript
// ens-ethers-test.js
const { ethers } = require('ethers');

async function testENS() {
  // Connect to Ethereum mainnet
  const provider = new ethers.providers.JsonRpcProvider('https://mainnet.infura.io/v3/YOUR_INFURA_KEY');
  
  // Forward resolution: ENS name to address
  const address = await provider.resolveName('vitalik.eth');
  console.log('Address for vitalik.eth:', address);
  
  // Reverse resolution: address to ENS name
  const name = await provider.lookupAddress('0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045');
  console.log('Name for 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045:', name);
}

testENS().catch(console.error);
```

Run with:
```bash
npm install ethers
node ens-ethers-test.js
```

### Using Online ENS Tools

You can also use online tools to verify ENS resolution:

1. ENS App: https://app.ens.domains/
2. Etherscan ENS Lookup: https://etherscan.io/enslookup
