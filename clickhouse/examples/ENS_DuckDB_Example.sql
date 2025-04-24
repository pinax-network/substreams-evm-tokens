-- ENS DuckDB Example Queries
-- This file demonstrates how to work with ENS data in Parquet format using DuckDB

-- Assuming you have downloaded Parquet files with the following structure:
-- - ens_names.parquet (contains name/address mappings)
-- - ens_names_by_address.parquet (contains address/name mappings)
-- - ens_texts.parquet (contains text records)

-- Load the Parquet files
-- Note: Replace the file paths with your actual paths

-- Basic setup and data loading
-- ===========================

-- Create a view for the ENS names table
CREATE OR REPLACE VIEW ens_names AS
SELECT * FROM read_parquet('path/to/ens_names.parquet');

-- Create a view for the ENS names by address table
CREATE OR REPLACE VIEW ens_names_by_address AS
SELECT * FROM read_parquet('path/to/ens_names_by_address.parquet');

-- Create a view for the ENS text records table
CREATE OR REPLACE VIEW ens_texts AS
SELECT * FROM read_parquet('path/to/ens_texts.parquet');

-- Create key/value views similar to Clickhouse materialized views
-- ===========================

-- Forward resolution (name -> address)
CREATE OR REPLACE VIEW ens_key_value_mapping AS
SELECT 
    name AS key,
    address AS value,
    updated_at
FROM ens_names
WHERE address != '';

-- Reverse resolution (address -> name)
CREATE OR REPLACE VIEW ens_reverse_key_value_mapping AS
SELECT 
    address AS key,
    name AS value,
    updated_at
FROM ens_names_by_address
WHERE name != '';

-- Example Queries
-- ===========================

-- 1. Forward resolution: Get the Ethereum address for an ENS name
SELECT key AS ens_name, value AS ethereum_address
FROM ens_key_value_mapping
WHERE key = 'vitalik.eth';

-- 2. Reverse resolution: Get the ENS name for an Ethereum address
SELECT key AS ethereum_address, value AS ens_name
FROM ens_reverse_key_value_mapping
WHERE key = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045';

-- 3. Get the 10 most recently updated ENS name/address pairs
SELECT key AS ens_name, value AS ethereum_address, updated_at
FROM ens_key_value_mapping
ORDER BY updated_at DESC
LIMIT 10;

-- 4. Find all ENS names that start with a specific prefix
SELECT key AS ens_name, value AS ethereum_address
FROM ens_key_value_mapping
WHERE key LIKE 'vit%'
ORDER BY key;

-- 5. Count ENS names by TLD
SELECT 
    split_part(key, '.', -1) as tld,
    count(*) as count
FROM ens_key_value_mapping
GROUP BY tld
ORDER BY count DESC
LIMIT 10;

-- 6. Find addresses that own multiple ENS names
WITH address_counts AS (
    SELECT value AS address, count(*) as name_count
    FROM ens_key_value_mapping
    GROUP BY value
    HAVING name_count > 1
    ORDER BY name_count DESC
    LIMIT 10
)
SELECT 
    ac.address, 
    ac.name_count,
    list_aggr(kv.key) AS ens_names
FROM address_counts ac
JOIN ens_key_value_mapping kv ON ac.address = kv.value
GROUP BY ac.address, ac.name_count
ORDER BY ac.name_count DESC;

-- 7. Find ENS names registered in the last 30 days
SELECT key AS ens_name, value AS ethereum_address, updated_at
FROM ens_key_value_mapping
WHERE updated_at > CURRENT_DATE - INTERVAL 30 DAY
ORDER BY updated_at DESC;

-- 8. Join with text records to get additional information
SELECT 
    kv.key AS ens_name, 
    kv.value AS ethereum_address,
    t.key AS text_key,
    t.value AS text_value
FROM ens_key_value_mapping kv
JOIN ens_texts t ON kv.key = t.name
WHERE t.key IN ('url', 'email', 'avatar', 'description')
ORDER BY kv.key, t.key
LIMIT 100;

-- 9. Find addresses with both forward and reverse resolution
SELECT 
    f.key AS ens_name,
    f.value AS ethereum_address,
    r.value AS reverse_ens_name
FROM ens_key_value_mapping f
JOIN ens_reverse_key_value_mapping r ON f.value = r.key
LIMIT 100;

-- 10. Export results to a new Parquet file
COPY (
    SELECT key AS ens_name, value AS ethereum_address
    FROM ens_key_value_mapping
    ORDER BY key
) TO 'path/to/export/ens_key_value.parquet' (FORMAT PARQUET);

-- Note: DuckDB syntax may vary slightly from Clickhouse.
-- Some functions like extractAll() in Clickhouse are replaced with 
-- regex functions or split_part() in DuckDB.
