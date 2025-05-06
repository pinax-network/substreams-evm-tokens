-- EAS Attestations Table
CREATE TABLE IF NOT EXISTS attestations (
    tx_hash             FixedString(66),         -- The hash of the transaction containing the attestation
    evt_index           UInt32,                  -- The log/event index in the transaction
    timestamp           DateTime(0, 'UTC'),      -- The timestamp of the block containing the attestation
    block_num           UInt64,                  -- The block number containing the attestation
    uid                 FixedString(66),         -- Unique identifier for the attestation (32 bytes, hex encoded)
    recipient           FixedString(42),         -- The recipient address
    attester            FixedString(42),         -- The attester address
    schema_id           FixedString(66),         -- Schema UID (32 bytes, hex encoded)
    data                String,                  -- Raw encoded attestation data
    schema              String,                  -- Schema definition string
    decoded_data        String,                  -- Decoded data JSON

    INDEX idx_schema_id         (schema_id)        TYPE bloom_filter GRANULARITY 4,
    INDEX idx_block_num         (block_num)        TYPE minmax GRANULARITY 4,
    INDEX idx_timestamp         (timestamp)        TYPE minmax GRANULARITY 4,
    INDEX idx_recipient         (recipient)        TYPE bloom_filter GRANULARITY 4,
    INDEX idx_attester          (attester)         TYPE bloom_filter GRANULARITY 4
) ENGINE = ReplacingMergeTree(block_num)
ORDER BY (uid);
