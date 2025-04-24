-- Simplified ENS Schema for testing the key/value mapping

-- Base tables
CREATE TABLE IF NOT EXISTS ens_names
(
    name String,
    node String,
    owner String,
    address String,
    contenthash String,
    created_at DateTime,
    updated_at DateTime
)
ENGINE = MergeTree()
ORDER BY (name, updated_at);

CREATE TABLE IF NOT EXISTS ens_texts
(
    name String,
    node String,
    key String,
    value String,
    created_at DateTime,
    updated_at DateTime
)
ENGINE = MergeTree()
ORDER BY (name, key, updated_at);

-- Key/Value mapping views
CREATE VIEW IF NOT EXISTS ens_key_value_mapping
AS
SELECT
    name AS key,
    address AS value,
    updated_at
FROM ens_names
WHERE address != '';

CREATE VIEW IF NOT EXISTS ens_reverse_key_value_mapping
AS
SELECT
    address AS key,
    name AS value,
    updated_at
FROM ens_names
WHERE address != '';
