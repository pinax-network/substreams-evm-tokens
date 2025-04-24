-- ENS Resolver Example Queries

-- Get the Ethereum address for an ENS name
SELECT name, address
FROM ens_names
WHERE name = 'vitalik.eth';

-- Get the primary ENS name for an Ethereum address
SELECT address, name
FROM ens_primary_names
WHERE address = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045';

-- Get all text records for an ENS name
SELECT name, key, value
FROM ens_texts
WHERE name = 'vitalik.eth';

-- Get all information about an ENS name
SELECT *
FROM ens_name_details
WHERE name = 'vitalik.eth';

-- Get the 10 most recently registered ENS names
SELECT name, owner, created_at
FROM ens_names
ORDER BY created_at DESC
LIMIT 10;

-- Get the 10 ENS names with the most text records
SELECT n.name, count(t.key) as text_record_count
FROM ens_names n
LEFT JOIN ens_texts t ON n.name = t.name
GROUP BY n.name
ORDER BY text_record_count DESC
LIMIT 10;

-- Get all ENS names that expire in the next 30 days
SELECT name, owner, expiry
FROM ens_names
WHERE expiry > toUnixTimestamp(now())
  AND expiry < toUnixTimestamp(now() + INTERVAL 30 DAY)
ORDER BY expiry ASC;

-- Get all ENS names for a specific owner
SELECT name, address, expiry
FROM ens_names
WHERE owner = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045'
ORDER BY name ASC;

-- Get all ENS names with a specific text record
SELECT n.name, t.value
FROM ens_names n
JOIN ens_texts t ON n.name = t.name
WHERE t.key = 'url'
ORDER BY n.name ASC;

-- Get the distribution of ENS names by TLD
SELECT 
    arrayStringConcat(arraySlice(splitByChar('.', name), -1, 1)) as tld,
    count(*) as count
FROM ens_names
GROUP BY tld
ORDER BY count DESC;
