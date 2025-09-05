/* ===========================
   ERC-20 STATE TABLES
   =========================== */
CREATE TABLE IF NOT EXISTS metadata_decimals_state_latest (
    address    FixedString(42),
    decimals   UInt8,
    block_num  UInt32,
    timestamp  DateTime('UTC')
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address);

CREATE TABLE IF NOT EXISTS metadata_name_state_latest (
    address    FixedString(42),
    name       LowCardinality(String),  -- '' means removed
    block_num  UInt32,
    timestamp  DateTime('UTC'),

    INDEX idx_name (name) TYPE bloom_filter(0.005) GRANULARITY 1
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address);

CREATE TABLE IF NOT EXISTS metadata_symbol_state_latest (
    address    FixedString(42),
    symbol     LowCardinality(String),  -- '' means removed
    block_num  UInt32,
    timestamp  DateTime('UTC'),

    INDEX idx_symbol (symbol) TYPE bloom_filter(0.005) GRANULARITY 1
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address);

/* ===========================
   MATERIALIZED VIEWS (ROUTING)
   =========================== */
/* Note:
   - We fan out from your existing sources:
       - erc20_metadata_initialize (initial snapshot)
       - erc20_metadata_changes    (field updates)
   - Empty strings are stored as '' (not NULL). The final view will turn '' -> NULL.
*/

/* INITIALIZE fan-out */
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_metadata_decimals
TO metadata_decimals_state_latest AS
SELECT address, block_num, timestamp, decimals
FROM erc20_metadata_initialize;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_metadata_name
TO metadata_name_state_latest AS
SELECT address, block_num, timestamp, name
FROM erc20_metadata_initialize;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_metadata_symbol
TO metadata_symbol_state_latest AS
SELECT address, block_num, timestamp, symbol
FROM erc20_metadata_initialize;

/* CHANGES fan-out
   If you want to ensure only initialized addresses get updates,
   retain the JOIN to erc20_metadata_initialize as in your original.
*/
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_update_metadata_name
TO metadata_name_state_latest AS
SELECT address, block_num, timestamp, name
FROM erc20_metadata_changes AS c
WHERE name != '';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_update_metadata_symbol
TO metadata_symbol_state_latest AS
SELECT address, block_num, timestamp, symbol
FROM erc20_metadata_changes AS c
WHERE symbol != '';

/* ===========================
   ONE-TIME INSERT: Native asset
   =========================== */

INSERT INTO metadata_decimals_state_latest (address, decimals, block_num, timestamp)
VALUES ('0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', 18, toUInt64(0), 0, toDateTime(0, 'UTC'));

INSERT INTO erc20_name_state_latest (address, name, block_num, timestamp)
VALUES ('0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', 'Native', toUInt64(0), 0, toDateTime(0, 'UTC'));

INSERT INTO erc20_symbol_state_latest (address, symbol, block_num, timestamp)
VALUES ('0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', 'Native', toUInt64(0), 0, toDateTime(0, 'UTC'));
