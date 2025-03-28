-- contract creations events --
CREATE TABLE IF NOT EXISTS contract_creations  (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),
   date                 Date,

   -- ordering --
   ordinal              UInt64, -- storage_change.ordinal or balance_change.ordinal
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- transaction --
   transaction_id       FixedString(66),
   `from`               FixedString(42) COMMENT 'creator address',
   `to`                 FixedString(42),

   -- contract --
   address              FixedString(42) COMMENT 'contract address',

   -- indexes --
   INDEX idx_block_num          (block_num)           TYPE minmax GRANULARITY 4,
   INDEX idx_timestamp          (timestamp)           TYPE minmax GRANULARITY 4,
   INDEX idx_date               (date)                TYPE minmax GRANULARITY 4,
   INDEX idx_transaction_id     (transaction_id)      TYPE bloom_filter GRANULARITY 4,
   INDEX idx_from               (`from`)              TYPE bloom_filter GRANULARITY 4,
   INDEX idx_to                 (`to`)                TYPE bloom_filter GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (address)
ORDER BY (address);