-- ERC-20 Metadata Initialize --
CREATE TABLE IF NOT EXISTS metadata_initialize AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 Metadata Initialize';

ALTER TABLE metadata_initialize
    ADD COLUMN IF NOT EXISTS decimals             UInt8 COMMENT 'token decimals',
    ADD COLUMN IF NOT EXISTS name                 String COMMENT 'token name',
    ADD COLUMN IF NOT EXISTS symbol               String COMMENT 'token symbol',
    -- indexes (event) --
    ADD INDEX IF NOT EXISTS idx_name               (`name`)             TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_symbol             (`symbol`)           TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_decimals           (decimals)           TYPE minmax GRANULARITY 1;

-- ERC-20 Metadata Changes --
CREATE TABLE IF NOT EXISTS metadata_changes AS TEMPLATE_RPC_CALLS
COMMENT 'ERC-20 Metadata Changes';

ALTER TABLE metadata_changes
    ADD COLUMN IF NOT EXISTS name                 String COMMENT 'token name',
    ADD COLUMN IF NOT EXISTS symbol               String COMMENT 'token symbol',
    -- indexes (event) --
    ADD INDEX IF NOT EXISTS idx_name               (`name`)             TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_symbol             (`symbol`)           TYPE bloom_filter GRANULARITY 1;