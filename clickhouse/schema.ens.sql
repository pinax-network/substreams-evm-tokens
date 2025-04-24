-- ENS Schema for Clickhouse
-- Raw event data tables

-- NameRegistered events
CREATE TABLE IF NOT EXISTS ens_name_registered
(
    block_number UInt64,
    block_timestamp DateTime64(3, 'UTC'),
    transaction_hash String,
    name String,
    label String,
    owner String,
    cost UInt64,
    expires UInt64
)
ENGINE = ReplacingMergeTree
ORDER BY (block_number, transaction_hash);

-- TextChanged events
CREATE TABLE IF NOT EXISTS ens_text_changed
(
    block_number UInt64,
    block_timestamp DateTime64(3, 'UTC'),
    transaction_hash String,
    node String,
    key String,
    value String
)
ENGINE = ReplacingMergeTree
ORDER BY (block_number, transaction_hash);

-- ReverseClaim events
CREATE TABLE IF NOT EXISTS ens_reverse_claim
(
    block_number UInt64,
    block_timestamp DateTime64(3, 'UTC'),
    transaction_hash String,
    address String,
    node String
)
ENGINE = ReplacingMergeTree
ORDER BY (block_number, transaction_hash);

-- NameChanged events
CREATE TABLE IF NOT EXISTS ens_name_changed
(
    block_number UInt64,
    block_timestamp DateTime64(3, 'UTC'),
    transaction_hash String,
    node String,
    name String
)
ENGINE = ReplacingMergeTree
ORDER BY (block_number, transaction_hash);

-- AddrChanged events
CREATE TABLE IF NOT EXISTS ens_addr_changed
(
    block_number UInt64,
    block_timestamp DateTime64(3, 'UTC'),
    transaction_hash String,
    node String,
    address String
)
ENGINE = ReplacingMergeTree
ORDER BY (block_number, transaction_hash);

-- Aggregated data tables

-- Latest ENS name to address mapping
CREATE TABLE IF NOT EXISTS ens_names
(
    name String,
    address String,
    owner String,
    resolver String,
    ttl UInt64,
    expiry UInt64,
    created_at DateTime64(3, 'UTC'),
    updated_at DateTime64(3, 'UTC'),
    contenthash String DEFAULT '',
    PRIMARY KEY (name)
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY name;

-- Latest address to ENS name mapping (reverse resolution)
CREATE TABLE IF NOT EXISTS ens_names_by_address
(
    address String,
    name String,
    updated_at DateTime64(3, 'UTC'),
    PRIMARY KEY (address)
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY address;

-- Latest ENS text records
CREATE TABLE IF NOT EXISTS ens_texts
(
    name String,
    key String,
    value String,
    updated_at DateTime64(3, 'UTC'),
    PRIMARY KEY (name, key)
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY (name, key);

-- Views for easier querying

-- View to get the primary ENS name for an address
CREATE VIEW IF NOT EXISTS ens_primary_names AS
SELECT address, name
FROM ens_names_by_address
ORDER BY updated_at DESC;

-- View to get all text records for a name
CREATE VIEW IF NOT EXISTS ens_name_texts AS
SELECT n.name, n.address, t.key, t.value
FROM ens_names AS n
LEFT JOIN ens_texts AS t ON n.name = t.name
ORDER BY n.name, t.key;

-- View to get all information about an ENS name
CREATE VIEW IF NOT EXISTS ens_name_details AS
SELECT 
    n.name,
    n.address,
    n.owner,
    n.resolver,
    n.ttl,
    n.expiry,
    n.created_at,
    n.updated_at,
    n.contenthash,
    groupArray((t.key, t.value)) AS text_records
FROM ens_names AS n
LEFT JOIN ens_texts AS t ON n.name = t.name
GROUP BY 
    n.name,
    n.address,
    n.owner,
    n.resolver,
    n.ttl,
    n.expiry,
    n.created_at,
    n.updated_at,
    n.contenthash;
