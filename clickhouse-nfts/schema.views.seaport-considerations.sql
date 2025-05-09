-- Seaport Considerations --
-- A consideration is what the offerer expects in return for their offer. It’s essentially the "payment" they expect to receive, which can also be:
-- NFTs (ERC-721, ERC-1155)
-- FTs (ERC-20)
-- Native cryptocurrency (ETH, MATIC, etc.)
CREATE TABLE IF NOT EXISTS seaport_considerations (
    -- block --
    block_num  UInt32,
    timestamp  DateTime(0, 'UTC'),

    -- transaction --
    tx_hash    FixedString(66),

    -- order fulfilled --
    order_hash FixedString(66),
    consideration_idx UInt16,

    -- consideration --
    item_type  UInt8                COMMENT 'The type of asset (NFT, FT, ETH, etc.)',
    token      FixedString(42)      COMMENT 'The contract address of the offered asset',
    token_id   UInt256              COMMENT 'The token ID for NFTs or 0 for FTs and ETH',
    amount     UInt256              COMMENT 'The amount of the offered asset',
    recipient  FixedString(42)      COMMENT 'The address that should receive the consideration',

    -- indexes (block) --
    INDEX idx_block_num     (block_num)    TYPE minmax       GRANULARITY 4,
    INDEX idx_timestamp     (timestamp)    TYPE minmax       GRANULARITY 4,

    -- indexes (transaction) --
    INDEX idx_tx_hash       (tx_hash)      TYPE bloom_filter GRANULARITY 4,

    -- indexes (order) --
    INDEX idx_order_hash    (order_hash)   TYPE bloom_filter GRANULARITY 4,

    -- indexes (consideration) --
    INDEX idx_item_type     (item_type)    TYPE minmax GRANULARITY 4,
    INDEX idx_token_id      (token_id)     TYPE minmax GRANULARITY 4,
    INDEX idx_amount        (amount)       TYPE minmax GRANULARITY 4,
    INDEX idx_recipient     (recipient)    TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree()
ORDER BY (token, token_id, order_hash, consideration_idx);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_seaport_considerations
TO seaport_considerations
AS
SELECT
    order_hash,
    tx_hash,
    block_num,
    timestamp,

    row_number() OVER (PARTITION BY order_hash ORDER BY tupleElement(c, 2)) AS consideration_idx,
    tupleElement(c, 1) AS item_type,
    tupleElement(c, 2) AS token,
    tupleElement(c, 3) AS token_id,
    tupleElement(c, 4) AS amount,
    tupleElement(c, 5) AS recipient
FROM seaport_order_fulfilled
LEFT ARRAY JOIN consideration AS c;
