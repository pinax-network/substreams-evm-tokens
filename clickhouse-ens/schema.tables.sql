CREATE TABLE IF NOT EXISTS name_registered (
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

    -- event (v1 & v0) --
    name                 String,
    label                FixedString(66),
    node                 FixedString(66),
    owner                FixedString(42),
    base_cost            UInt64,
    expires              DateTime(0, 'UTC'),

    -- event (v1) --
    premium              UInt64,

    -- event (base) --
    token_id             UInt256
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS name_renewed (
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
    name                 String,
    label                FixedString(66),
    node                 FixedString(66),
    cost                 UInt64,
    expires              DateTime(0, 'UTC')
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS text_changed (
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
    node                 FixedString(66),
    key                  String,
    value                String,
    indexed_key          FixedString(66)
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS reverse_claimed (
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
    node                 FixedString(66),
    address              FixedString(42),
)
ENGINE = ReplacingMergeTree
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS name_changed (
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
    node                 FixedString(66),
    name                 String
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS address_changed (
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
    node                 String,
    address              FixedString(42),
    coin_type            UInt64 COMMENT 'coin type (e.g. 60 for ETH)'
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);


CREATE TABLE IF NOT EXISTS content_hash_changed (
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
    node                 FixedString(66),
    hash                 String
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

CREATE TABLE IF NOT EXISTS new_owner (
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
    node                 FixedString(66),
    label                FixedString(66),
    owner                FixedString(42)
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);
