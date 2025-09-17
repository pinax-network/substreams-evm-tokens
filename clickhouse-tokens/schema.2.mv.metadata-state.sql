/* ===========================
   ERC-20 Metadata STATE TABLES
   =========================== */
CREATE TABLE IF NOT EXISTS metadata_decimals_state_latest AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 metadata decimals state';
ALTER TABLE metadata_decimals_state_latest ADD COLUMN IF NOT EXISTS decimals UInt8 COMMENT 'token decimals';

CREATE TABLE IF NOT EXISTS metadata_name_state_latest AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 metadata name state';
ALTER TABLE metadata_name_state_latest ADD COLUMN IF NOT EXISTS name LowCardinality(String) COMMENT 'token name';

CREATE TABLE IF NOT EXISTS metadata_symbol_state_latest AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 metadata symbol state';
ALTER TABLE metadata_symbol_state_latest ADD COLUMN IF NOT EXISTS symbol LowCardinality(String) COMMENT 'token symbol';

/* ===========================
   MATERIALIZED VIEWS (ROUTING)
   =========================== */
/* Note:
   - We fan out from your existing sources:
       - metadata_initialize (initial snapshot)
       - metadata_changes    (field updates)
   - Empty strings are stored as '' (not NULL). The final view will turn '' -> NULL.
*/

/* INITIALIZE fan-out */
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_metadata_decimals
TO metadata_decimals_state_latest AS
SELECT contract, block_num, timestamp, block_hash, decimals
FROM metadata_initialize;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_metadata_name
TO metadata_name_state_latest AS
SELECT contract, block_num, timestamp, block_hash, name
FROM metadata_initialize;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_initialize_metadata_symbol
TO metadata_symbol_state_latest AS
SELECT contract, block_num, timestamp, block_hash, symbol
FROM metadata_initialize;

/* CHANGES fan-out
   If you want to ensure only initialized addresses get updates,
   retain the JOIN to metadata_initialize as in your original.
*/
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_update_metadata_name
TO metadata_name_state_latest AS
SELECT contract, block_num, timestamp, block_hash, name
FROM metadata_changes AS c
WHERE name != '';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_update_metadata_symbol
TO metadata_symbol_state_latest AS
SELECT contract, block_num, timestamp, block_hash, symbol
FROM metadata_changes AS c
WHERE symbol != '';
