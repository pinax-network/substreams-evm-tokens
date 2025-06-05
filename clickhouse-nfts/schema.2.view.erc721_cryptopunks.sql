CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc721_cryptopunks_metadata
TO erc721_metadata_by_token
AS
SELECT
    block_num,
    block_hash,
    timestamp,
    contract,
    token_id,
    concat(
        'https://wrappedpunks.com:3000/api/punks/metadata/',  -- base URI
        toString(token_id)                                    -- token_id → text
    ) AS uri
FROM erc721_transfers
WHERE contract = '0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb';

INSERT INTO erc721_metadata_by_contract (
    -- block --
    block_num,
    block_hash,
    timestamp,
    -- event --
    contract,
    symbol,
    name
)
VALUES (
    3914495,
    '',
    toDateTime(0, 'UTC'),
    '0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb',
    'CRYPTOPUNKS',
    'Ͼ'
);

INSERT INTO erc721_total_supply (
    -- block --
    block_num,
    block_hash,
    timestamp,
    -- event --
    contract,
    total_supply
)
VALUES (
    3914495,
    '',
    toDateTime(0, 'UTC'),
    '0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb',
    10000
);

INSERT INTO erc721_base_uri (
    -- block --
    block_num,
    block_hash,
    timestamp,
    -- event --
    contract,
    base_uri
)
VALUES (
    3914495,
    '',
    toDateTime(0, 'UTC'),
    '0xb47e3cd837ddf8e4c57f05d70ab865de6e193bbb',
    'https://wrappedpunks.com:3000/api/punks/metadata/'
);