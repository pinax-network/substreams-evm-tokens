-- Seaport Order Fulfilled --
CREATE TABLE IF NOT EXISTS seaport_order_fulfilled (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    ordinal              UInt64, -- log.ordinal
    `index`              UInt64, -- relative index
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

    -- transaction --
    tx_hash              FixedString(66),

    -- call --
    caller               FixedString(42) COMMENT 'caller address', -- call.caller

    -- log --
    contract             FixedString(42) COMMENT 'contract address',

    -- event --
    order_hash           FixedString(66),
    offerer              FixedString(42),
    zone                 FixedString(42),
    recipient            FixedString(42),

    -- event (JSON) --
    offer_raw            String, -- JSON object as string
    offer Array(Tuple(
        UInt8,         -- item_type
        FixedString(42), -- token
        UInt256, -- identifier
        UInt256  -- amount
    )) MATERIALIZED (
        arrayMap(
            x -> tuple(
                toUInt8(JSONExtract(x, 'item_type', 'UInt8')),
                JSONExtract(x, 'token', 'FixedString(42)'),
                toUInt256(JSONExtract(x, 'identifier', 'String')),
                toUInt256(JSONExtract(x, 'amount', 'String'))
            ),
            JSONExtractArrayRaw(offer_raw)
        )
    ),

    consideration_raw       String, -- JSON object as string
    consideration Array(Tuple(
        UInt8,         -- item_type
        FixedString(42), -- token
        UInt256, -- identifier
        UInt256, -- amount
        FixedString(42)  -- recipient
    )) MATERIALIZED (
        arrayMap(
            x -> tuple(
                toUInt8(JSONExtract(x, 'item_type', 'UInt8')),
                JSONExtract(x, 'token', 'FixedString(42)'),
                toUInt256(JSONExtract(x, 'identifier', 'String')),
                toUInt256(JSONExtract(x, 'amount', 'String')),
                JSONExtract(x, 'recipient', 'FixedString(42)')
            ),
            JSONExtractArrayRaw(consideration_raw)
        )
    ),

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)                 TYPE bloom_filter GRANULARITY 4,
    INDEX idx_order_hash         (order_hash)               TYPE bloom_filter GRANULARITY 4,
    INDEX idx_offerer            (offerer)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_zone               (zone)                     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_recipient          (recipient)                TYPE bloom_filter GRANULARITY 4
) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- Seaport Orders Matched --
CREATE TABLE IF NOT EXISTS seaport_orders_matched (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    ordinal              UInt64, -- log.ordinal
    `index`              UInt64, -- relative index
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

    -- transaction --
    tx_hash              FixedString(66),

    -- call --
    caller               FixedString(42) COMMENT 'caller address', -- call.caller

    -- log --
    contract             FixedString(42) COMMENT 'contract address',

    -- event --
    order_hashes_raw       String, -- as comma separated list
    order_hashes           Array(FixedString(66)) MATERIALIZED splitByChar(',', order_hashes_raw),

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)                 TYPE bloom_filter GRANULARITY 4

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- Seaport Order Cancelled --
CREATE TABLE IF NOT EXISTS seaport_order_cancelled (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    ordinal              UInt64, -- log.ordinal
    `index`              UInt64, -- relative index
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

    -- transaction --
    tx_hash              FixedString(66),

    -- call --
    caller               FixedString(42) COMMENT 'caller address', -- call.caller

    -- log --
    contract             FixedString(42) COMMENT 'contract address',

    -- event --
    order_hash           FixedString(66),
    offerer              FixedString(42),
    zone                 FixedString(42),

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)                 TYPE bloom_filter GRANULARITY 4,
    INDEX idx_order_hash         (order_hash)               TYPE bloom_filter GRANULARITY 4,
    INDEX idx_offerer            (offerer)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_zone               (zone)                     TYPE bloom_filter GRANULARITY 4

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);
