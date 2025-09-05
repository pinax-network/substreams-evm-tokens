/* ===========================
   ERC-20 STATE TABLES
   =========================== */
CREATE TABLE IF NOT EXISTS erc20_decimals_state_latest (
    address    FixedString(42),
    decimals   UInt8,
    version    UInt64,               -- use block_num as version
    block_num  UInt32,
    timestamp  DateTime('UTC')
)
ENGINE = ReplacingMergeTree(version)
ORDER BY (address);

CREATE TABLE IF NOT EXISTS erc20_name_state_latest (
    address    FixedString(42),
    name       LowCardinality(String),  -- '' means removed
    version    UInt64,
    block_num  UInt32,
    timestamp  DateTime('UTC'),

    INDEX idx_name (name) TYPE bloom_filter(0.005) GRANULARITY 1
)
ENGINE = ReplacingMergeTree(version)
ORDER BY (address);

CREATE TABLE IF NOT EXISTS erc20_symbol_state_latest (
    address    FixedString(42),
    symbol     LowCardinality(String),  -- '' means removed
    version    UInt64,
    block_num  UInt32,
    timestamp  DateTime('UTC'),

    INDEX idx_symbol (symbol) TYPE bloom_filter(0.005) GRANULARITY 1
)
ENGINE = ReplacingMergeTree(version)
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
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_erc20_decimals
TO erc20_decimals_state_latest AS
SELECT
    address,
    version,
    block_num,
    timestamp,
    decimals
FROM erc20_metadata_initialize;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_erc20_name
TO erc20_name_state_latest AS
SELECT
    address,
    version,
    block_num,
    timestamp,
    name  -- keep '' as-is to represent removed/unknown
FROM erc20_metadata_initialize;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_erc20_symbol
TO erc20_symbol_state_latest AS
SELECT
    address,
    version,
    block_num,
    timestamp,
    symbol  -- keep '' as-is to represent removed/unknown
FROM erc20_metadata_initialize;

/* CHANGES fan-out
   If you want to ensure only initialized addresses get updates,
   retain the JOIN to erc20_metadata_initialize as in your original.
*/
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_update_erc20_name
TO erc20_name_state_latest AS
SELECT
    c.address,
    toUInt64(c.block_num) AS version,
    c.block_num,
    c.timestamp,
    c.name   -- '' = removed
FROM erc20_metadata_changes AS c
JOIN erc20_metadata_initialize i USING (address);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_update_erc20_symbol
TO erc20_symbol_state_latest AS
SELECT
    c.address,
    toUInt64(c.block_num) AS version,
    c.block_num,
    c.timestamp,
    c.symbol  -- '' = removed
FROM erc20_metadata_changes AS c
JOIN erc20_metadata_initialize i USING (address);

/* If you also capture decimals updates in erc20_metadata_changes, enable this:
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_update_erc20_decimals
TO erc20_decimals_state_latest AS
SELECT
    c.address,
    toUInt64(c.block_num) AS version,
    c.block_num,
    c.timestamp,
    c.decimals
FROM erc20_metadata_changes AS c
JOIN erc20_metadata_initialize i USING (address)
WHERE c.decimals IS NOT NULL;
*/

/* ===========================
   ONE-TIME INSERT: Native asset
   =========================== */

INSERT INTO erc20_decimals_state_latest (address, decimals, version, block_num, timestamp)
VALUES ('0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', 18, toUInt64(0), 0, toDateTime(0, 'UTC'));

INSERT INTO erc20_name_state_latest (address, name, version, block_num, timestamp)
VALUES ('0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', 'Native', toUInt64(0), 0, toDateTime(0, 'UTC'));

INSERT INTO erc20_symbol_state_latest (address, symbol, version, block_num, timestamp)
VALUES ('0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', 'Native', toUInt64(0), 0, toDateTime(0, 'UTC'));

/* ===========================
   UNIFIED "LATEST" VIEW
   ===========================
   - Uses argMax(value, version) per field.
   - Converts '' back to NULL for name/symbol to match your prior semantics.
   - Includes a latest (by version) block_num/timestamp across any field for convenience.
*/

CREATE OR REPLACE VIEW erc20_metadata AS
WITH
  dc AS (
    SELECT address, argMax(decimals, version) AS decimals
    FROM erc20_decimals_state_latest
    GROUP BY address
  ),
  nm AS (
    SELECT address, argMax(name, version) AS name_raw
    FROM erc20_name_state_latest
    GROUP BY address
  ),
  sb AS (
    SELECT address, argMax(symbol, version) AS symbol_raw
    FROM erc20_symbol_state_latest
    GROUP BY address
  ),
  bt AS (
    /* latest block/timestamp across any field */
    SELECT
      address,
      argMax(block_num, version)  AS block_num,
      argMax(timestamp, version)  AS timestamp
    FROM (
      SELECT address, version, block_num, timestamp FROM erc20_decimals_state_latest
      UNION ALL
      SELECT address, version, block_num, timestamp FROM erc20_name_state_latest
      UNION ALL
      SELECT address, version, block_num, timestamp FROM erc20_symbol_state_latest
    )
    GROUP BY address
  ),
  acc AS (
    /* all addresses that have appeared anywhere */
    SELECT address FROM erc20_decimals_state_latest
    UNION DISTINCT SELECT address FROM erc20_name_state_latest
    UNION DISTINCT SELECT address FROM erc20_symbol_state_latest
  )
SELECT
  acc.address,
  bt.block_num,
  bt.timestamp,
  dc.decimals,
  NULLIF(nm.name_raw,   '') AS name,
  NULLIF(sb.symbol_raw, '') AS symbol
FROM acc
LEFT JOIN bt ON bt.address = acc.address
LEFT JOIN dc ON dc.address = acc.address
LEFT JOIN nm ON nm.address = acc.address
LEFT JOIN sb ON sb.address = acc.address;
