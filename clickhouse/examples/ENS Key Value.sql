-- ENS Key/Value Example Queries

-- Basic key/value lookups

-- 1. Forward resolution: Get the Ethereum address for an ENS name
SELECT key AS ens_name, value AS ethereum_address
FROM ens_key_value_mapping
WHERE key = 'vitalik.eth';

-- 2. Reverse resolution: Get the ENS name for an Ethereum address
SELECT key AS ethereum_address, value AS ens_name
FROM ens_reverse_key_value_mapping
WHERE key = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045';

-- Advanced queries

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
    arrayStringConcat(arraySlice(splitByChar('.', key), -1, 1)) as tld,
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
    groupArray(kv.key) AS ens_names
FROM address_counts ac
JOIN ens_key_value_mapping kv ON ac.address = kv.value
GROUP BY ac.address, ac.name_count
ORDER BY ac.name_count DESC;

-- 7. Find ENS names registered in the last 30 days
SELECT key AS ens_name, value AS ethereum_address, updated_at
FROM ens_key_value_mapping
WHERE updated_at > now() - INTERVAL 30 DAY
ORDER BY updated_at DESC;

-- 8. Find common patterns in ENS names
SELECT 
    extractAll(key, '[a-z0-9]+')[1] AS first_part,
    count(*) AS count
FROM ens_key_value_mapping
GROUP BY first_part
HAVING count > 5
ORDER BY count DESC
LIMIT 20;

-- 9. Join with text records to get additional information
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

-- 10. Find addresses with both forward and reverse resolution
SELECT 
    f.key AS ens_name,
    f.value AS ethereum_address,
    r.value AS reverse_ens_name
FROM ens_key_value_mapping f
JOIN ens_reverse_key_value_mapping r ON f.value = r.key
LIMIT 100;
