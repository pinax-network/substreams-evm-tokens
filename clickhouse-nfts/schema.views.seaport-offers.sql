-- Seaport Offers --
-- An offer in Seaport is the asset(s) a seller is willing to give up in exchange for the desired consideration. This can include:
-- NFTs (ERC-721, ERC-1155)
-- FTs (ERC-20)
-- Native cryptocurrency (ETH, MATIC, etc.)
CREATE TABLE IF NOT EXISTS seaport_offers (
    -- block --
    block_num  UInt32,
    timestamp  DateTime(0, 'UTC'),

    -- transaction --
    tx_hash    FixedString(66),

    -- order fulfilled --
    order_hash FixedString(66),
    offer_idx  UInt16,

    -- offer --
    item_type  UInt8                COMMENT 'The type of asset (NFT, FT, ETH, etc.)',
    token      FixedString(42)      COMMENT 'The contract address of the offered asset',
    token_id   UInt256              COMMENT 'The token ID for NFTs or 0 for FTs and ETH',
    amount     UInt256              COMMENT 'The amount of the offered asset',

    -- indexes (block) --
    INDEX idx_block_num   (block_num)   TYPE minmax       GRANULARITY 4,
    INDEX idx_timestamp   (timestamp)   TYPE minmax       GRANULARITY 4,

    -- indexes (transaction) --
    INDEX idx_tx_hash     (tx_hash)     TYPE bloom_filter GRANULARITY 4,

    -- indexes (order) --
    INDEX idx_order_hash  (order_hash)  TYPE bloom_filter GRANULARITY 4,

    -- indexes (offer) --
    INDEX idx_item_type   (item_type)   TYPE minmax       GRANULARITY 1,
    INDEX idx_token_id    (token_id)    TYPE bloom_filter GRANULARITY 4,
    INDEX idx_amount      (amount)      TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree()
ORDER BY (token, token_id, order_hash, offer_idx);   -- cluster by the fields people filter on

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_seaport_offers
TO seaport_offers
AS
SELECT
    order_hash,
    tx_hash,
    block_num,
    timestamp,

    -- enumerate positions so we can keep the original order if needed
    row_number() OVER (PARTITION BY order_hash ORDER BY tupleElement(o, 2)) AS offer_idx,
    tupleElement(o, 1) AS item_type,
    tupleElement(o, 2) AS token,
    tupleElement(o, 3) AS token_id,
    tupleElement(o, 4) AS amount
FROM seaport_order_fulfilled
LEFT ARRAY JOIN offer AS o
-- ERC721 and ERC1155 --
WHERE item_type IN (2, 3);
