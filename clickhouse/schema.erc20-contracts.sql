-- ERC-20 contracts metadata events --
CREATE TABLE IF NOT EXISTS contract_changes  (
   -- block --
   block_num            UInt32,
   block_hash           FixedString(66),
   timestamp            DateTime(0, 'UTC'),
   date                 Date,

   -- ordering --
   -- ordinal              UInt64 COMMENT 'NOT IMPLEMENTED', -- log.ordinal
   `index`              UInt64, -- relative index
   global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

   -- -- transaction --
   -- transaction_id       FixedString(66) COMMENT 'NOT IMPLEMENTED',
   -- `from`               FixedString(42) COMMENT 'NOT IMPLEMENTED: ERC-20 creator/modifier address',
   -- `to`                 FixedString(42) COMMENT 'NOT IMPLEMENTED',

   -- contract --
   address              FixedString(42) COMMENT 'ERC-20 contract address',
   name                 String COMMENT 'ERC-20 contract name (typically 3-8 characters)',
   symbol               String COMMENT 'ERC-20 contract symbol (typically 3-4 characters)',
   decimals             UInt8 COMMENT 'ERC-20 contract decimals (18 by default)',

   -- -- debug --
   -- algorithm            LowCardinality(String) COMMENT 'NOT IMPLEMENTED',
   -- algorithm_code       UInt8 COMMENT 'NOT IMPLEMENTED',

   -- indexes --
   -- INDEX idx_transaction_id      (transaction_id)     TYPE bloom_filter GRANULARITY 4,
   -- INDEX idx_from                (`from`)             TYPE bloom_filter GRANULARITY 4,
   -- INDEX idx_to                  (`to`)               TYPE bloom_filter GRANULARITY 4,
   INDEX idx_address             (address)            TYPE bloom_filter GRANULARITY 4,
   INDEX idx_name                (name)               TYPE bloom_filter GRANULARITY 4,
   INDEX idx_symbol              (symbol)             TYPE bloom_filter GRANULARITY 4,
   INDEX idx_decimals            (decimals)           TYPE minmax GRANULARITY 4,
   -- INDEX idx_algorithm           (algorithm)          TYPE set(2) GRANULARITY 4,
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (date, block_num, `index`)
ORDER BY (date, block_num, `index`);