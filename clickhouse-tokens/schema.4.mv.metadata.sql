CREATE TABLE IF NOT EXISTS metadata (
    contract         String,
    name             LowCardinality(String),
    symbol           LowCardinality(String),
    decimals         UInt8,

    -- indexes --
    INDEX idx_name (name) TYPE bloom_filter(0.005) GRANULARITY 1,
    INDEX idx_symbol (symbol) TYPE bloom_filter(0.005) GRANULARITY 1,
    INDEX idx_decimals (decimals) TYPE minmax GRANULARITY 1
)
ENGINE = ReplacingMergeTree
ORDER BY (contract);

-- 1) MV: refresh on name changes
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_metadata_from_name
TO metadata AS
SELECT contract, name, symbol, decimals
FROM (SELECT DISTINCT contract FROM metadata_name_state_latest) AS changed
INNER JOIN metadata_view USING (contract);

-- 2) MV: refresh on symbol changes
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_metadata_from_symbol
TO metadata AS
SELECT contract, name, symbol, decimals
FROM (SELECT DISTINCT contract FROM metadata_symbol_state_latest) AS changed
INNER JOIN metadata_view USING (contract);

-- 3) MV: refresh on decimals changes
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_metadata_from_decimals
TO metadata AS
SELECT contract, name, symbol, decimals
FROM (SELECT DISTINCT contract FROM metadata_decimals_state_latest) AS changed
INNER JOIN metadata_view USING (contract);
