-- CryptoPunk Assigns --
CREATE TABLE IF NOT EXISTS punk_assigns (
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
    `to`                 FixedString(42),
    punk_index           UInt64,

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)                 TYPE set(16) GRANULARITY 4,
    INDEX idx_to                 (`to`)                     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_punk_index         (punk_index)               TYPE set(128) GRANULARITY 4,

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- CryptoPunk Transfers --
CREATE TABLE IF NOT EXISTS punk_transfers (
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
    `from`               FixedString(42),
    `to`                 FixedString(42),
    punk_index           UInt64,

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)                 TYPE set(16) GRANULARITY 4,
    INDEX idx_from               (`from`)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_to                 (`to`)                     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_punk_index         (punk_index)               TYPE set(128) GRANULARITY 4,

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- CryptoPunk Bought --
CREATE TABLE IF NOT EXISTS punk_bought (
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
    `from`               FixedString(42),
    `to`                 FixedString(42),
    punk_index           UInt64,
    value                UInt256,
    value_is_null        Bool,

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)                 TYPE set(16) GRANULARITY 4,
    INDEX idx_from               (`from`)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_to                 (`to`)                     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_punk_index         (punk_index)               TYPE set(128) GRANULARITY 4,

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- CryptoPunk BidEntered --
CREATE TABLE IF NOT EXISTS punk_bid_entered (
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
    `from`               FixedString(42),
    punk_index           UInt64,
    value                UInt256,

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)                 TYPE set(16) GRANULARITY 4,
    INDEX idx_from               (`from`)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_punk_index         (punk_index)               TYPE set(128) GRANULARITY 4,

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- CryptoPunk BidWithdrawn --
CREATE TABLE IF NOT EXISTS punk_bid_withdrawn AS punk_bid_entered
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- CryptoPunk NoLongerForSale --
CREATE TABLE IF NOT EXISTS punk_no_longer_for_sale (
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
    punk_index           UInt64,

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)                 TYPE set(16) GRANULARITY 4,
    INDEX idx_punk_index         (punk_index)               TYPE set(128) GRANULARITY 4,

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- CryptoPunk PunkOffered --
CREATE TABLE IF NOT EXISTS punk_offered (
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
    `to`                 FixedString(42),
    punk_index           UInt64,
    min_value            UInt256,

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_contract           (contract)                 TYPE set(16) GRANULARITY 4,
    INDEX idx_to                 (`to`)                     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_punk_index         (punk_index)               TYPE set(128) GRANULARITY 4,
    INDEX idx_min_value          (min_value)                TYPE minmax GRANULARITY 4,

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);