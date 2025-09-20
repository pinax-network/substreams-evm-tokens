/* DECIMALS */
CREATE OR REPLACE VIEW metadata_decimals_view AS
SELECT
  contract,
  max(block_num) AS block_num,
  argMax(timestamp, block_num) AS timestamp,
  argMax(decimals, block_num) AS decimals
FROM metadata_decimals_state_latest AS m
GROUP BY contract;

/* NAME */
CREATE OR REPLACE VIEW metadata_name_view AS
SELECT
  contract,
  max(block_num) AS block_num,
  argMax(timestamp, block_num) AS timestamp,
  argMax(name, block_num) AS name
FROM metadata_name_state_latest AS m
GROUP BY contract;

/* SYMBOL */
CREATE OR REPLACE VIEW metadata_symbol_view AS
SELECT
  contract,
  max(block_num) AS block_num,
  argMax(timestamp, block_num) AS timestamp,
  argMax(symbol, block_num) AS symbol
FROM metadata_symbol_state_latest AS m
GROUP BY contract;

/* COMBINED VIEW */
CREATE OR REPLACE VIEW metadata_view AS
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
