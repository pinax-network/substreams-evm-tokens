-- ERC-20 Metadata Initialize --
CREATE TABLE IF NOT EXISTS erc20_metadata_initialize (
    -- block --
    block_num            UInt32,
    timestamp            DateTime(0, 'UTC'),

    -- event --
    address              FixedString(42),
    decimals             UInt8,
    name                 Nullable(String),
    symbol               Nullable(String)
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address);

-- ERC-20 Metadata Changes --
CREATE TABLE IF NOT EXISTS erc20_metadata_changes (
    -- block --
    block_num            UInt32,
    timestamp            DateTime(0, 'UTC'),

    -- event --
    address              FixedString(42),
    name                 Nullable(String),
    symbol               Nullable(String)
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (address);

-- Insert tokens for testing purposes
INSERT INTO erc20_metadata_initialize (address, decimals) VALUES
    (lower('0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'), 18),
    (lower('0x0000000000000000000000000000000000000000'), 18),
    (lower('0xdac17f958d2ee523a2206206994597c13d831ec7'), 6),
    (lower('0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'), 6),
    (lower('0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'), 18);

-- Native ETH
-- Native ETH
-- USDT
-- USDC
-- WETH