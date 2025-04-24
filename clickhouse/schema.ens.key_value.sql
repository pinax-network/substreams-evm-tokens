-- ENS Key/Value Schema for Clickhouse
-- This schema creates a simplified key/value table for ENS names and addresses

-- Create a materialized view that provides a clean key/value mapping
-- between ENS names and Ethereum addresses
CREATE MATERIALIZED VIEW IF NOT EXISTS ens_key_value_mapping
ENGINE = ReplacingMergeTree
ORDER BY name
POPULATE AS
SELECT 
    name AS key,
    address AS value,
    updated_at
FROM ens_names
WHERE address != '';

-- Create a materialized view for reverse lookups (address to name)
CREATE MATERIALIZED VIEW IF NOT EXISTS ens_reverse_key_value_mapping
ENGINE = ReplacingMergeTree
ORDER BY address
POPULATE AS
SELECT 
    address AS key,
    name AS value,
    updated_at
FROM ens_names_by_address
WHERE name != '';

-- Example queries:

-- 1. Get the Ethereum address for an ENS name
-- SELECT key, value FROM ens_key_value_mapping WHERE key = 'vitalik.eth';

-- 2. Get the ENS name for an Ethereum address
-- SELECT key, value FROM ens_reverse_key_value_mapping WHERE key = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045';

-- 3. Get the 10 most recently updated ENS name/address pairs
-- SELECT key, value FROM ens_key_value_mapping ORDER BY updated_at DESC LIMIT 10;

-- 4. Get all ENS names that start with a specific prefix
-- SELECT key, value FROM ens_key_value_mapping WHERE key LIKE 'vit%' ORDER BY key;

-- 5. Get all addresses that have an ENS name
-- SELECT key, value FROM ens_reverse_key_value_mapping ORDER BY key LIMIT 100;
