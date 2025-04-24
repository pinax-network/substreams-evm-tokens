# ENS Substreams

This substreams module indexes Ethereum Name Service (ENS) data, providing both forward resolution (ENS name to Ethereum address) and reverse resolution (Ethereum address to ENS name).

## Overview

The ENS Substreams module tracks the following events:

- Name registrations
- Name transfers
- Address changes
- Text record changes
- Reverse claims

## Contracts

The module indexes events from the following ENS contracts:

| Name | Address |
|------|---------|
| Registry with Fallback | 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e |
| Public Resolver | 0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63 |
| Public Resolver 2 | 0x4976fb03C32e5B8cfe2b6cCB31c09Ba78EBaBa41 |
| Reverse Registry | 0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb |
| ETH Registrar Controller | 0x253553366da8546fc250f225fe3d25d0c782303b |
| ETH Registrar Controller (Old) | 0x283Af0B28c62C092C9727F1Ee09c02CA627EB7F5 |
| Name Wrapper | 0xD4416b13d2b3a9aBae7AcD5D6C2BbDBE25686401 |

## Modules

### map_events

This module maps Ethereum blocks to ENS events, extracting all relevant ENS events from the transaction logs.

### store_ens_names

This module stores ENS names and their associated data, including:
- Owner address
- Resolver address
- Ethereum address
- Text records
- TTL
- Expiry date

### resolve_ens_name

This module resolves an ENS name to an Ethereum address. It takes a name parameter (with or without the .eth suffix) and returns the associated Ethereum address.

Example:
```
vitalik.eth => 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045
```

### reverse_resolve

This module resolves an Ethereum address to its primary ENS name. It takes an address parameter and returns the associated ENS name.

Example:
```
0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045 => vitalik.eth
```

## Clickhouse Integration

The ENS Substreams module includes Clickhouse integration for storing and querying ENS data. The following tables are created:

### Raw Event Data

- `ens_name_registered`: Records of name registration events
- `ens_text_changed`: Records of text record changes
- `ens_reverse_claim`: Records of reverse claim events
- `ens_name_changed`: Records of name change events
- `ens_addr_changed`: Records of address change events

### Aggregated Data

- `ens_names`: Latest mapping of ENS names to Ethereum addresses
- `ens_names_by_address`: Reverse mapping of Ethereum addresses to ENS names
- `ens_texts`: Latest mapping of ENS names and keys to text record values

### Views

- `ens_primary_names`: View to get the primary ENS name for an address
- `ens_name_texts`: View to get all text records for a name
- `ens_name_details`: View to get all information about an ENS name

## Usage

To run the ENS Substreams module:

```bash
substreams run substreams.yaml map_events -e <endpoint> -s <start-block>
```

To resolve an ENS name:

```bash
substreams run substreams.yaml resolve_ens_name -e <endpoint> -s <start-block> --params "vitalik.eth"
```

To reverse resolve an address:

```bash
substreams run substreams.yaml reverse_resolve -e <endpoint> -s <start-block> --params "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045"
```

## Example Queries

### Get the Ethereum address for an ENS name

```sql
SELECT name, address FROM ens_names WHERE name = 'vitalik.eth'
```

### Get the primary ENS name for an Ethereum address

```sql
SELECT address, name FROM ens_primary_names WHERE address = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'
```

### Get all text records for an ENS name

```sql
SELECT name, key, value FROM ens_texts WHERE name = 'vitalik.eth'
```

### Get all information about an ENS name

```sql
SELECT * FROM ens_name_details WHERE name = 'vitalik.eth'
