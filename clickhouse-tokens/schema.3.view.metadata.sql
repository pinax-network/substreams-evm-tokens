-- Token metadata view --
CREATE OR REPLACE VIEW metadata AS
WITH
  dc AS (SELECT address, argMax(decimals, block_num) AS decimals FROM erc20_decimals_state_latest GROUP BY address ),
  nm AS (SELECT address, argMax(name, block_num) AS name FROM erc20_name_state_latest GROUP BY address ),
  sb AS (SELECT address, argMax(symbol, block_num) AS symbol FROM erc20_symbol_state_latest GROUP BY address )
SELECT
  acc.address AS address,
  bt.block_num,
  bt.timestamp,
  dc.decimals,
  nm.name,
  sb.symbol
FROM
  (
    SELECT address FROM erc20_decimals_state_latest
    UNION DISTINCT SELECT address FROM erc20_name_state_latest
    UNION DISTINCT SELECT address FROM erc20_symbol_state_latest
  ) AS acc
LEFT JOIN dc ON dc.address = acc.address
LEFT JOIN nm ON nm.address = acc.address
LEFT JOIN sb ON sb.address = acc.address;
