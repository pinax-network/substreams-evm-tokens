-- detect how many unique values
WITH t AS (
    SELECT * FROM swaps LIMIT 8192 OFFSET 120000
) SELECT
    uniq(sender),
    uniq(caller),
    uniq(pool),
    uniq(recipient),
    uniq(tx_from),
    uniq(tx_to),
FROM t

-- detect how many unique values by Pool
WITH t AS (
    SELECT * FROM swaps WHERE pool = lower('0xA43fe16908251ee70EF74718545e4FE6C5cCEc9f') ORDER BY protocol, tx_to, pool, sender LIMIT 8192 OFFSET 31000
) SELECT
    uniq(protocol),
    uniq(pool), -- AMM pool
    uniq(tx_to), -- Swap router
    uniq(sender),
    uniq(caller),
    uniq(tx_from),
    uniq(recipient),
FROM t

-- Total unique values by Pool
-- V4 ETH/USDT = 0x72331fcb696b0151904c03584b66dc8365bc63f8a144d89a773384e3a579ca73
-- V3 ETH/USDC = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640
-- V2 ETH/USDT = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852
WITH t AS (
    SELECT * FROM swaps WHERE pool = lower('0x72331fcb696b0151904c03584b66dc8365bc63f8a144d89a773384e3a579ca73') ORDER BY protocol, pool, tx_to, sender, caller, recipient, tx_from LIMIT 8192 OFFSET 0
) SELECT
    uniq(protocol),
    uniq(pool), -- AMM pool
    uniq(tx_to), -- Swap router
    uniq(sender),
    uniq(caller),
    uniq(tx_from),
    uniq(recipient),
    uniq(tx_hash),
FROM t

WITH t AS (
    SELECT * FROM swaps LIMIT 8192 OFFSET 0
) SELECT
    uniq(protocol),
    uniq(pool), -- AMM pool
    uniq(tx_to), -- Swap router
    uniq(sender),
    uniq(caller),
    uniq(tx_from),
    uniq(recipient),
    uniq(tx_hash),
FROM t

-- ALL UNIQUE --
-- V4 ETH/USDT = 0x72331fcb696b0151904c03584b66dc8365bc63f8a144d89a773384e3a579ca73
   ┌─uniq(protocol)─┬─uniq(pool)─┬─uniq(tx_to)─┬─uniq(sender)─┬─uniq(caller)─┬─uniq(tx_from)─┬─uniq(recipient)─┐
1. │              1 │          1 │        4643 │          184 │          184 │       110,583 │               0 │
   └────────────────┴────────────┴─────────────┴──────────────┴──────────────┴───────────────┴─────────────────┘

-- V3 ETH/USDC = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640
   ┌─uniq(protocol)─┬─uniq(pool)─┬─uniq(tx_to)─┬─uniq(sender)─┬─uniq(caller)─┬─uniq(tx_from)─┬─uniq(recipient)─┐
1. │              1 │          1 │       22966 │         3243 │         3243 │     1,544,759 │          454871 │
   └────────────────┴────────────┴─────────────┴──────────────┴──────────────┴───────────────┴─────────────────┘

-- V2 ETH/USDT = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852
   ┌─uniq(protocol)─┬─uniq(pool)─┬─uniq(tx_to)─┬─uniq(sender)─┬─uniq(caller)─┬─uniq(tx_from)─┬─uniq(recipient)─┐
1. │              1 │          1 │       11655 │         2919 │         2919 │     1,474,234 │          519125 │
   └────────────────┴────────────┴─────────────┴──────────────┴──────────────┴───────────────┴─────────────────┘


-- PER GRANULE --
-- V4 ETH/USDT = 0x72331fcb696b0151904c03584b66dc8365bc63f8a144d89a773384e3a579ca73
   ┌─uniq(protocol)─┬─uniq(pool)─┬─uniq(tx_to)─┬─uniq(sender)─┬─uniq(caller)─┬─uniq(tx_from)─┬─uniq(recipient)─┐
1. │              1 │          1 │           2 │            4 │            4 │          5644 │               0 │
   └────────────────┴────────────┴─────────────┴──────────────┴──────────────┴───────────────┴─────────────────┘

-- V3 ETH/USDC = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640
   ┌─uniq(protocol)─┬─uniq(pool)─┬─uniq(tx_to)─┬─uniq(sender)─┬─uniq(caller)─┬─uniq(tx_from)─┬─uniq(recipient)─┐
1. │              1 │          1 │          13 │           11 │           11 │            63 │             299 │
   └────────────────┴────────────┴─────────────┴──────────────┴──────────────┴───────────────┴─────────────────┘

-- V2 ETH/USDT = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852
   ┌─uniq(protocol)─┬─uniq(pool)─┬─uniq(tx_to)─┬─uniq(sender)─┬─uniq(caller)─┬─uniq(tx_from)─┬─uniq(recipient)─┐
1. │              1 │          1 │           7 │            8 │            8 │          3568 │             542 │
   └────────────────┴────────────┴─────────────┴──────────────┴──────────────┴───────────────┴─────────────────┘

