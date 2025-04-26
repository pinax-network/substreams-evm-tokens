-- ERC-1155 Transfers Table
CREATE TABLE IF NOT EXISTS erc1155_transfers (
    block_num        UInt64,
    tx_hash          FixedString(66),
    log_index        UInt64,
    contract         FixedString(42),
    operator         FixedString(42),
    from             FixedString(42),
    to               FixedString(42),
    token_id         String,
    amount           String
) ENGINE = ReplacingMergeTree
PRIMARY KEY (block_num, tx_hash, log_index)
ORDER BY (block_num, tx_hash, log_index);

-- ERC-1155 Transactions Table
CREATE TABLE IF NOT EXISTS erc1155_transactions (
    block_number             UInt64,
    block_timestamp          UInt64,
    block_hash               FixedString(66),
    tx_hash                  FixedString(66),
    nonce                    UInt64,
    position                 UInt32,
    from_address             FixedString(42),
    to_address               FixedString(42),
    value                    String,
    tx_fee                   String,
    gas_price                String,
    gas_limit                UInt64,
    gas_used                 UInt64,
    cumulative_gas_used      UInt64,
    max_fee_per_gas          String,
    max_priority_fee_per_gas String,
    input                    String,
    type                     Int32,
    v                        String,
    r                        String,
    s                        String
) ENGINE = ReplacingMergeTree
PRIMARY KEY (block_number, tx_hash)
ORDER BY (block_number, tx_hash);

CREATE TABLE IF NOT EXISTS erc1155_tokens (
    block_num   UInt64,
    tx_hash     FixedString(66),
    log_index   UInt64,
    contract    FixedString(42),
    token_id    String,
    uri         String
) ENGINE = ReplacingMergeTree
PRIMARY KEY (block_num, tx_hash, log_index)
ORDER BY (block_num, tx_hash, log_index);
