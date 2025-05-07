-- ERC721 Transfers --
CREATE TABLE IF NOT EXISTS erc721_transfers (
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
    operator             FixedString(42) DEFAULT '',
    from                 FixedString(42),
    to                   FixedString(42),
    token_id             UInt256,
    amount               UInt256 DEFAULT 1,

    -- classification --
    transfer_type           Enum8('Single' = 1, 'Batch' = 2),
    token_standard          Enum8('ERC721' = 1, 'ERC1155' = 2),

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)                 TYPE bloom_filter GRANULARITY 4,
    INDEX idx_operator           (operator)                 TYPE bloom_filter GRANULARITY 4,
    INDEX idx_from               (from)                     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_to                 (to)                       TYPE bloom_filter GRANULARITY 4,
    INDEX idx_token_id           (token_id)                 TYPE minmax GRANULARITY 4,
    INDEX idx_amount             (amount)                   TYPE minmax GRANULARITY 4,
    INDEX idx_transfer_type      (transfer_type)            TYPE set(1) GRANULARITY 1,
    INDEX idx_token_standard     (token_standard)           TYPE set(1) GRANULARITY 1

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- ERC721 Approval --
CREATE TABLE IF NOT EXISTS erc721_approvals (
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
    owner                   FixedString(42),
    approved                FixedString(42),
    token_id                UInt256,

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)             TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)              TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)            TYPE bloom_filter GRANULARITY 4,
    INDEX idx_owner              (owner)               TYPE bloom_filter GRANULARITY 4,
    INDEX idx_approved           (approved)            TYPE bloom_filter GRANULARITY 4,
    INDEX idx_token_id           (token_id)            TYPE minmax GRANULARITY 4

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- ERC721 Approval For All --
CREATE TABLE IF NOT EXISTS erc721_approvals_for_all (
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
    owner                   FixedString(42),
    operator                FixedString(42),
    approved                Bool,

    -- classification --
    token_standard          Enum8('ERC721' = 1, 'ERC1155' = 2),

    -- indexes --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)                 TYPE bloom_filter GRANULARITY 4,
    INDEX idx_owner              (owner)                    TYPE bloom_filter GRANULARITY 4,
    INDEX idx_operator           (operator)                 TYPE bloom_filter GRANULARITY 4,
    INDEX idx_approved           (approved)                 TYPE set(1) GRANULARITY 1,
    INDEX idx_token_standard     (token_standard)           TYPE set(1) GRANULARITY 1

) ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- ERC721 Token Metadata --
CREATE TABLE IF NOT EXISTS erc721_metadata_by_contract (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- log --
    contract            FixedString(42) COMMENT 'contract address',

    -- metadata --
    symbol              String DEFAULT '',
    name                String DEFAULT '',
    base_uri            String DEFAULT '',

    -- indexes --
    INDEX idx_symbol             (symbol)              TYPE bloom_filter GRANULARITY 4,
    INDEX idx_name               (name)                TYPE bloom_filter GRANULARITY 4,
    INDEX idx_base_uri           (base_uri)            TYPE bloom_filter GRANULARITY 4

) ENGINE = ReplacingMergeTree(block_num)
ORDER BY (contract);

CREATE TABLE IF NOT EXISTS erc721_total_supply (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- log --
    contract            FixedString(42) COMMENT 'contract address',

    -- metadata --
    total_supply        UInt256

) ENGINE = ReplacingMergeTree(block_num)
ORDER BY (contract);

CREATE TABLE IF NOT EXISTS erc721_metadata_by_token (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- log --
    contract            FixedString(42) COMMENT 'contract address',
    token_id            UInt256,

    -- metadata --
    uri                 String DEFAULT ''
) ENGINE = ReplacingMergeTree(block_num)
PRIMARY KEY (contract, token_id)
ORDER BY (contract, token_id);
