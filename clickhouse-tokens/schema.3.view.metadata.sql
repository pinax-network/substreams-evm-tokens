-- Token metadata view --
CREATE OR REPLACE VIEW metadata_view AS
WITH
  dc AS (SELECT contract, argMax(decimals, block_num) AS decimals FROM metadata_decimals_state_latest GROUP BY contract ),
  nm AS (SELECT contract, argMax(name, block_num) AS name FROM metadata_name_state_latest GROUP BY contract ),
  sb AS (SELECT contract, argMax(symbol, block_num) AS symbol FROM metadata_symbol_state_latest GROUP BY contract )
SELECT
  acc.contract as contract,
  dc.decimals as decimals,
  nm.name as name,
  sb.symbol as symbol
FROM
  (
    SELECT contract FROM metadata_decimals_state_latest
    UNION DISTINCT SELECT contract FROM metadata_name_state_latest
    UNION DISTINCT SELECT contract FROM metadata_symbol_state_latest
  ) AS acc
LEFT JOIN dc ON dc.contract = acc.contract
LEFT JOIN nm ON nm.contract = acc.contract
LEFT JOIN sb ON sb.contract = acc.contract;
