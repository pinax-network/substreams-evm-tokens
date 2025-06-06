CREATE TABLE IF NOT EXISTS seaport_orders (
    -- block --
    block_num           UInt32,
    timestamp           DateTime(0, 'UTC'),

    -- transaction --
    tx_hash             FixedString(66),

    -- order fulfilled --
    order_hash                  FixedString(66),
    offerer                     FixedString(42),
    zone                        FixedString(42),
    recipient                   FixedString(42),

    -- offer --
    offer_index                 UInt16,
    offer_item_type             UInt8,
    offer_token                 FixedString(42),
    offer_token_id              UInt256,
    offer_amount                UInt256,

    -- consideration --
    consideration_item_type     UInt8,
    consideration_token         FixedString(42),
    consideration_token_id      UInt256,
    consideration_amount        UInt256,
    consideration_recipient     FixedString(42),

    -- indexes (block) --
    INDEX idx_block_num         (block_num)         TYPE minmax GRANULARITY 4,
    INDEX idx_timestamp         (timestamp)         TYPE minmax GRANULARITY 4,

    -- indexes (transaction) --
    INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,

    -- indexes (order) --
    INDEX idx_order_hash        (order_hash)        TYPE bloom_filter GRANULARITY 4,
    INDEX idx_offerer           (offerer)           TYPE bloom_filter GRANULARITY 4,
    INDEX idx_zone              (zone)              TYPE bloom_filter GRANULARITY 4,
    INDEX idx_recipient         (recipient)         TYPE bloom_filter GRANULARITY 4,

    -- indexes (offer) --
    INDEX idx_offer_item_type   (offer_item_type)   TYPE minmax GRANULARITY 4,
    INDEX idx_offer_token_id    (offer_token_id)    TYPE minmax GRANULARITY 4,
    INDEX idx_offer_amount      (offer_amount)      TYPE minmax GRANULARITY 4,
    INDEX idx_offer_token       (offer_token)       TYPE bloom_filter GRANULARITY 4,

    -- indexes (consideration) --
    INDEX idx_consideration_item_type   (consideration_item_type) TYPE minmax GRANULARITY 4,
    INDEX idx_consideration_token_id    (consideration_token_id)  TYPE minmax GRANULARITY 4,
    INDEX idx_consideration_amount      (consideration_amount)    TYPE minmax GRANULARITY 4,
    INDEX idx_consideration_token       (consideration_token)     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_consideration_recipient   (consideration_recipient) TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree()
ORDER BY (offer_token, offer_token_id, order_hash, offer_index);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_seaport_orders
TO seaport_orders
AS
SELECT
    -- block --
    f.block_num,
    f.timestamp,

    -- transaction --
    f.tx_hash,

    -- order fulfilled --
    f.order_hash,
    f.offerer,
    f.zone,
    f.recipient,

    -- offer --
    row_number() OVER (PARTITION BY f.order_hash ORDER BY tupleElement(o,2)) AS offer_index,
    tupleElement(o,1)  AS offer_item_type,
    tupleElement(o,2)  AS offer_token,
    tupleElement(o,3)  AS offer_token_id,
    toUInt256(tupleElement(o,4)) AS offer_amount,

    -- consideration --
    tupleElement(c,1)            AS consideration_item_type,
    tupleElement(c,2)            AS consideration_token,
    tupleElement(c,3)            AS consideration_token_id,
    toUInt256(tupleElement(c,4)) AS consideration_amount,
    tupleElement(c,5)            AS consideration_recipient

FROM seaport_order_fulfilled AS f
LEFT ARRAY JOIN f.offer AS o
LEFT ARRAY JOIN f.consideration AS c;
