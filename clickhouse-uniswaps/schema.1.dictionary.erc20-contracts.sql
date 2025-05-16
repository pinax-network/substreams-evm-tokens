-- Minimal ERC-20 contracts --
CREATE TABLE IF NOT EXISTS erc20_contracts (
   address        FixedString(42),
   decimals       UInt8
)
ENGINE = ReplacingMergeTree
ORDER BY (address);