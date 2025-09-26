-- DELETE MV's --
DROP TABLE IF EXISTS mv_metadata_from_decimals ON CLUSTER 'tokenapis-b';
DROP TABLE IF EXISTS mv_metadata_from_name ON CLUSTER 'tokenapis-b';
DROP TABLE IF EXISTS mv_metadata_from_symbol ON CLUSTER 'tokenapis-b';
DROP TABLE IF EXISTS metadata ON CLUSTER 'tokenapis-b';
DROP VIEW IF EXISTS metadata_view ON CLUSTER 'tokenapis-b';

/* DECIMALS */
CREATE OR REPLACE VIEW metadata_decimals_view ON CLUSTER 'tokenapis-b' AS
SELECT
  contract,
  max(block_num) AS block_num,
  max(timestamp) AS timestamp,
  argMax(decimals, m.block_num) AS decimals
FROM metadata_decimals_state_latest AS m
GROUP BY contract;

/* NAME */
CREATE OR REPLACE VIEW metadata_name_view ON CLUSTER 'tokenapis-b' AS
SELECT
  contract,
  max(block_num) AS block_num,
  max(timestamp) AS timestamp,
  argMax(name, m.block_num) AS name
FROM metadata_name_state_latest AS m
GROUP BY contract;

/* SYMBOL */
CREATE OR REPLACE VIEW metadata_symbol_view ON CLUSTER 'tokenapis-b' AS
SELECT
  contract,
  max(block_num) AS block_num,
  max(timestamp) AS timestamp,
  argMax(symbol, m.block_num) AS symbol
FROM metadata_symbol_state_latest AS m
GROUP BY contract;

/* COMBINED VIEW */
CREATE OR REPLACE VIEW metadata_view ON CLUSTER 'tokenapis-b' AS
WITH
  decimals AS (
    SELECT contract, block_num, timestamp, decimals FROM metadata_decimals_view
  ),
  names AS (
    SELECT contract, block_num, timestamp, name FROM metadata_name_view
  ),
  symbols AS (
    SELECT contract, block_num, timestamp, symbol FROM metadata_symbol_view
  ),
  contracts AS (
    SELECT contract FROM metadata_decimals_state_latest
    UNION DISTINCT SELECT contract FROM metadata_name_state_latest
    UNION DISTINCT SELECT contract FROM metadata_symbol_state_latest
  )
SELECT
  c.contract AS contract,
  coalesce(d.block_num, n.block_num, s.block_num) AS block_num,
  coalesce(d.timestamp, n.timestamp, s.timestamp) AS timestamp,
  d.decimals AS decimals,
  nullIf(n.name, '') AS name,
  nullIf(s.symbol, '') AS symbol
FROM contracts AS c
LEFT JOIN decimals AS d USING (contract)
LEFT JOIN names AS n USING (contract)
LEFT JOIN symbols AS s USING (contract);
