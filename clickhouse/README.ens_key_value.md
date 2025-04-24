# ENS Key/Value Mapping

This document explains the ENS key/value mapping implementation for Clickhouse and DuckDB.

## Overview

The ENS (Ethereum Name Service) key/value mapping provides a simplified interface for resolving ENS names to Ethereum addresses and vice versa. This implementation creates materialized views on top of the existing ENS tables to provide a clean, key/value interface for querying ENS data.

## Schema

The implementation consists of two materialized views:

1. `ens_key_value_mapping`: Maps ENS names (keys) to Ethereum addresses (values)
2. `ens_reverse_key_value_mapping`: Maps Ethereum addresses (keys) to ENS names (values)

These views are defined in `schema.ens.key_value.sql`.

## Clickhouse Implementation

### Setup

To set up the key/value mapping in Clickhouse:

1. Ensure the base ENS tables are already created using `schema.ens.sql`
2. Run the `schema.ens.key_value.sql` script to create the materialized views

```bash
clickhouse-client --multiline --queries-file=schema.ens.key_value.sql
```

### Example Queries

See `examples/ENS Key Value.sql` for a comprehensive set of example queries, including:

- Basic name and address resolution
- Finding names with specific patterns
- Analyzing name distribution by TLD
- Finding addresses with multiple ENS names
- Joining with text records for additional information

## DuckDB Implementation

For working with ENS data in Parquet format using DuckDB:

1. Download the Parquet files containing ENS data
2. Use the `examples/ENS_DuckDB_Example.sql` script as a template

The DuckDB example demonstrates:

- Loading Parquet files
- Creating views similar to the Clickhouse materialized views
- Running the same types of queries as in Clickhouse
- Exporting results to new Parquet files

## Data Structure

The key/value mapping simplifies the more complex ENS data structure:

- **Keys**: Either ENS names (e.g., `vitalik.eth`) or Ethereum addresses (e.g., `0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045`)
- **Values**: The corresponding address or name
- **updated_at**: Timestamp of the last update to the mapping

## Use Cases

The key/value mapping is useful for:

1. Simple name resolution services
2. Address lookups
3. Analytics on ENS name patterns and ownership
4. Integration with other systems that need a simplified interface to ENS data

## Performance Considerations

The materialized views are optimized for quick lookups by key. For more complex queries or access to additional ENS data (like text records, content hashes, etc.), you may need to join with the base tables.
