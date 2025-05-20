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

CREATE TABLE IF NOT EXISTS erc721_metadata_by_token (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- log --
    contract            FixedString(42) COMMENT 'contract address',

    -- metadata --
    token_id            UInt256,
    uri                 String DEFAULT ''
) ENGINE = ReplacingMergeTree(block_num)
PRIMARY KEY (contract, token_id)
ORDER BY (contract, token_id);


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