-- This file is generated. Do not edit.

CREATE TABLE IF NOT EXISTS cursors
(
    id        String,
    cursor    String,
    block_num Int64,
    block_id  String
)
    ENGINE = ReplacingMergeTree()
        PRIMARY KEY (id)
        ORDER BY (id);

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


-- ERC1155 Transfer Single & Batch --
CREATE TABLE IF NOT EXISTS erc1155_transfers as erc721_transfers
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- ERC1155 Approval For All --
CREATE TABLE IF NOT EXISTS erc1155_approvals_for_all as erc721_approvals_for_all
ENGINE = ReplacingMergeTree
PRIMARY KEY (timestamp, block_num, `index`)
ORDER BY (timestamp, block_num, `index`);

-- ERC1155 Token Metadata --
CREATE TABLE IF NOT EXISTS erc1155_metadata_by_token as erc721_metadata_by_token
ENGINE = ReplacingMergeTree(block_num)
PRIMARY KEY (contract, token_id)
ORDER BY (contract, token_id);


-- Seaport Order Fulfilled --
CREATE TABLE IF NOT EXISTS seaport_order_fulfilled (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    ordinal              UInt64, -- log.ordinal
    `index`              UInt64, -- relative index
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)
    global_sequence_reverse  UInt64 MATERIALIZED global_sequence * -1,

    -- transaction --
    tx_hash              FixedString(66),

    -- call --
    caller               FixedString(42) COMMENT 'caller address', -- call.caller

    -- log --
    contract             FixedString(42) COMMENT 'contract address',

    -- event --
    order_hash           FixedString(66),
    offerer              FixedString(42),
    zone                 FixedString(42),
    recipient            FixedString(42),

    -- event (JSON) --
    offer_raw            String, -- JSON object as string
    offer Array(Tuple(
        UInt8,         -- item_type
        FixedString(42), -- token
        UInt256, -- identifier
        UInt256  -- amount
    )) MATERIALIZED (
        arrayMap(
            x -> tuple(
                toUInt8(JSONExtract(x, 'item_type', 'UInt8')),
                JSONExtract(x, 'token', 'FixedString(42)'),
                toUInt256(JSONExtract(x, 'identifier', 'String')),
                toUInt256(JSONExtract(x, 'amount', 'String'))
            ),
            JSONExtractArrayRaw(offer_raw)
        )
    ),
    consideration_raw       String, -- JSON object as string
    consideration Array(Tuple(
        UInt8,         -- item_type
        FixedString(42), -- token
        UInt256, -- identifier
        UInt256, -- amount
        FixedString(42)  -- recipient
    )) MATERIALIZED (
        arrayMap(
            x -> tuple(
                toUInt8(JSONExtract(x, 'item_type', 'UInt8')),
                JSONExtract(x, 'token', 'FixedString(42)'),
                toUInt256(JSONExtract(x, 'identifier', 'String')),
                toUInt256(JSONExtract(x, 'amount', 'String')),
                JSONExtract(x, 'recipient', 'FixedString(42)')
            ),
            JSONExtractArrayRaw(consideration_raw)
        )
    ),

    -- indexes (block) --
    INDEX idx_timestamp            (timestamp)              TYPE minmax GRANULARITY 4,
    INDEX idx_block_num            (block_num)              TYPE minmax GRANULARITY 4,

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)                 TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_offerer            (offerer)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_zone               (zone)                     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_recipient          (recipient)                TYPE bloom_filter GRANULARITY 4
) ENGINE = ReplacingMergeTree(global_sequence_reverse) -- only keep first event --
ORDER BY (order_hash); -- contains duplicates --

-- Seaport Orders Matched --
CREATE TABLE IF NOT EXISTS seaport_orders_matched (
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
    order_hashes_raw       String, -- as comma separated list
    order_hashes           Array(FixedString(66)) MATERIALIZED splitByChar(',', order_hashes_raw),

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)                 TYPE bloom_filter GRANULARITY 4

) ENGINE = MergeTree
ORDER BY (timestamp, block_num, `index`);

-- Seaport Order Cancelled --
CREATE TABLE IF NOT EXISTS seaport_order_cancelled (
    -- block --
    block_num            UInt32,
    block_hash           FixedString(66),
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    ordinal              UInt64, -- log.ordinal
    `index`              UInt64, -- relative index
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)
    global_sequence_reverse  UInt64 MATERIALIZED global_sequence * -1,

    -- transaction --
    tx_hash              FixedString(66),

    -- call --
    caller               FixedString(42) COMMENT 'caller address', -- call.caller

    -- log --
    contract             FixedString(42) COMMENT 'contract address',

    -- event --
    order_hash           FixedString(66),
    offerer              FixedString(42),
    zone                 FixedString(42),

    -- indexes (block) --
    INDEX idx_timestamp            (timestamp)              TYPE minmax GRANULARITY 4,
    INDEX idx_block_num            (block_num)              TYPE minmax GRANULARITY 4,

    -- indexes (transaction) --
    INDEX idx_tx_hash            (tx_hash)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_caller             (caller)                   TYPE bloom_filter GRANULARITY 4,
    INDEX idx_contract           (contract)                 TYPE bloom_filter GRANULARITY 4,

    -- indexes (event) --
    INDEX idx_offerer            (offerer)                  TYPE bloom_filter GRANULARITY 4,
    INDEX idx_zone               (zone)                     TYPE bloom_filter GRANULARITY 4

) ENGINE = ReplacingMergeTree(global_sequence_reverse) -- only keep first event --
ORDER BY (order_hash); -- contains duplicates --


-- Offchain Metadata
CREATE TABLE IF NOT EXISTS metadata (
    contract            FixedString(42),
    token_id            UInt256,
    timestamp           DateTime(0, 'UTC') DEFAULT now(),
    metadata_json       String DEFAULT '',                  -- metadata JSON response
    image_uri           String DEFAULT '',                  -- image URI
    description         String DEFAULT '',                  -- description from metadata
    rarity              LowCardinality(String) DEFAULT '',  -- rarity from metadata
    image_saved         Boolean DEFAULT false,              -- whether the image has been saved to S3
    image_mime_type     LowCardinality(String) DEFAULT '',  -- image MIME type
    image_size_bytes    UInt64 DEFAULT 0,                   -- image size in bytes

    INDEX idx_timestamp             (timestamp)            TYPE minmax GRANULARITY 4,
    INDEX idx_image_saved           (image_saved)          TYPE set(2) GRANULARITY 4,
    INDEX idx_description           (description)          TYPE bloom_filter GRANULARITY 4,
    INDEX idx_rarity                (rarity)               TYPE set(32) GRANULARITY 4
) ENGINE = ReplacingMergeTree(timestamp)
PRIMARY KEY (contract, token_id)
ORDER BY (contract, token_id);

-- Metadata requests and query results
CREATE TABLE IF NOT EXISTS metadata_requests (
    contract        FixedString(42),
    token_id        UInt256,
    timestamp       DateTime(0, 'UTC') DEFAULT now(),
    uri             String,                         -- metadata URI being requested
    url             String,                         -- actual URL being requested (can be different from uri, i.e. ipfs://xxx vs https://ipfs.com/xxx)
    status          Enum8('ok' = 0, 'timeout' = 1, 'host_not_found' = 2, 'connection_refused' = 3, 'connection_reset' = 4, 'http_error' = 5, 'other_error' = 6),
    http_code       UInt16 DEFAULT 0,               -- HTTP status code
    success         Boolean DEFAULT false,          -- whether the request was successful
    metadata_json   String DEFAULT '',              -- metadata JSON response
    duration_ms     UInt64 DEFAULT 0,               -- duration of the request in milliseconds

    INDEX idx_success       (success) TYPE set(2) GRANULARITY 4,
    INDEX idx_http_code     (http_code) TYPE set(32) GRANULARITY 4,
    INDEX idx_status        (status)  TYPE set(16) GRANULARITY 4,
    INDEX idx_duration_ms   (duration_ms) TYPE minmax GRANULARITY 4
) ENGINE = MergeTree
PRIMARY KEY (contract, token_id, timestamp)
ORDER BY (contract, token_id, timestamp);

-- Spam Scoring
CREATE TABLE IF NOT EXISTS spam_scoring (
    contract        FixedString(42),
    timestamp       DateTime(0, 'UTC') DEFAULT now(),  -- when the score was assigned
    spam_score      UInt16,                                 -- score from 0 (not spam) to 100 (definitely spam)
    classification  LowCardinality(String) DEFAULT '',      -- ? e.g., 'spam', 'not_spam', 'suspicious'
    reason          String DEFAULT '',                      -- ? optional: explanation or model output
    source          LowCardinality(String) DEFAULT '',      -- ? which service/model provided this score

    INDEX idx_timestamp      (timestamp)      TYPE minmax GRANULARITY 4,
    INDEX idx_spam_score     (spam_score)     TYPE minmax GRANULARITY 4,
    INDEX idx_classification (classification) TYPE set(8)  GRANULARITY 4,
    INDEX idx_source         (source)         TYPE set(8)  GRANULARITY 4,
    INDEX idx_reason         (reason)         TYPE bloom_filter GRANULARITY 4
) ENGINE = ReplacingMergeTree(timestamp)
PRIMARY KEY (contract)
ORDER BY (contract);


CREATE TABLE IF NOT EXISTS erc1155_balances (
    -- block --
    block_num            SimpleAggregateFunction(max, UInt32),
    timestamp            SimpleAggregateFunction(max, DateTime(0, 'UTC')),

    -- ordering --
    global_sequence      SimpleAggregateFunction(max, UInt64), -- latest global sequence (block_num << 32 + index)

    -- balance --
    contract             FixedString(42),
    token_id             UInt256,
    owner                FixedString(42),
    balance              SimpleAggregateFunction(sum, Int256)
)
ENGINE = AggregatingMergeTree
ORDER BY (contract, token_id, owner);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc1155_balance_to
TO erc1155_balances
AS
SELECT
    block_num,
    timestamp,
    global_sequence,
    contract,
    token_id,
    `to` AS owner,
    CAST(amount, 'Int256') AS balance
FROM erc1155_transfers;

CREATE MATERIALIZED VIEW IF NOT EXISTS  mv_erc1155_balance_from
TO erc1155_balances
AS
SELECT
    block_num,
    timestamp,
    global_sequence,
    contract,
    token_id,
    `from` AS owner,
    -CAST(amount, 'Int256') as balance
FROM erc1155_transfers;


CREATE TABLE IF NOT EXISTS erc721_owners (
    -- block --
    block_num            UInt32,
    timestamp            DateTime(0, 'UTC'),

    -- ordering --
    global_sequence      UInt64, -- latest global sequence (block_num << 32 + index)

    -- owners --
    contract             FixedString(42) COMMENT 'contract address',
    token_id             UInt256,
    owner                FixedString(42),

    -- indexes --
    INDEX idx_owner      (owner)    TYPE bloom_filter GRANULARITY 4
) ENGINE = ReplacingMergeTree(global_sequence)
ORDER BY (contract, token_id);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_erc721_owners
TO erc721_owners
AS
SELECT
    -- block --
    block_num,
    timestamp,

    -- ordering --
    global_sequence,

    -- owners --
    contract,
    token_id,
    to AS owner          -- current owner after this transfer
FROM erc721_transfers;


CREATE TABLE IF NOT EXISTS seaport_orders (
    -- block --
    block_num           UInt32,
    timestamp           DateTime(0, 'UTC'),

    -- transaction --
    tx_hash             FixedString(66),

    -- order fulfilled --
    order_hash                  FixedString(66),
    offerer                     FixedString(42),
    zone                        FixedString(42),
    recipient                   FixedString(42),

    -- offer --
    offer_index                 UInt16,
    offer_item_type             UInt8,
    offer_token                 FixedString(42),
    offer_token_id              UInt256,
    offer_amount                UInt256,

    -- consideration --
    consideration_item_type     UInt8,
    consideration_token         FixedString(42),
    consideration_token_id      UInt256,
    consideration_amount        UInt256,
    consideration_recipient     FixedString(42),

    -- indexes (block) --
    INDEX idx_block_num         (block_num)         TYPE minmax GRANULARITY 4,
    INDEX idx_timestamp         (timestamp)         TYPE minmax GRANULARITY 4,

    -- indexes (transaction) --
    INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter GRANULARITY 4,

    -- indexes (order) --
    INDEX idx_order_hash        (order_hash)        TYPE bloom_filter GRANULARITY 4,
    INDEX idx_offerer           (offerer)           TYPE bloom_filter GRANULARITY 4,
    INDEX idx_zone              (zone)              TYPE bloom_filter GRANULARITY 4,
    INDEX idx_recipient         (recipient)         TYPE bloom_filter GRANULARITY 4,

    -- indexes (offer) --
    INDEX idx_offer_item_type   (offer_item_type)   TYPE minmax GRANULARITY 4,
    INDEX idx_offer_token_id    (offer_token_id)    TYPE minmax GRANULARITY 4,
    INDEX idx_offer_amount      (offer_amount)      TYPE minmax GRANULARITY 4,
    INDEX idx_offer_token       (offer_token)       TYPE bloom_filter GRANULARITY 4,

    -- indexes (consideration) --
    INDEX idx_consideration_item_type   (consideration_item_type) TYPE minmax GRANULARITY 4,
    INDEX idx_consideration_token_id    (consideration_token_id)  TYPE minmax GRANULARITY 4,
    INDEX idx_consideration_amount      (consideration_amount)    TYPE minmax GRANULARITY 4,
    INDEX idx_consideration_token       (consideration_token)     TYPE bloom_filter GRANULARITY 4,
    INDEX idx_consideration_recipient   (consideration_recipient) TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree()
ORDER BY (offer_token, offer_token_id, order_hash, offer_index);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_seaport_orders
TO seaport_orders
AS
SELECT
    -- block --
    f.block_num,
    f.timestamp,

    -- transaction --
    f.tx_hash,

    -- order fulfilled --
    f.order_hash,
    f.offerer,
    f.zone,
    f.recipient,

    -- offer --
    row_number() OVER (PARTITION BY f.order_hash ORDER BY tupleElement(o,2)) AS offer_index,
    tupleElement(o,1)  AS offer_item_type,
    tupleElement(o,2)  AS offer_token,
    tupleElement(o,3)  AS offer_token_id,
    toUInt256(tupleElement(o,4)) AS offer_amount,

    -- consideration --
    tupleElement(c,1)            AS consideration_item_type,
    tupleElement(c,2)            AS consideration_token,
    tupleElement(c,3)            AS consideration_token_id,
    toUInt256(tupleElement(c,4)) AS consideration_amount,
    tupleElement(c,5)            AS consideration_recipient

FROM seaport_order_fulfilled AS f
LEFT ARRAY JOIN f.offer AS o
LEFT ARRAY JOIN f.consideration AS c
-- ERC721 and ERC1155 --
WHERE offer_item_type IN (2, 3);


-- Seaport Considerations --
-- A consideration is what the offerer expects in return for their offer. It’s essentially the "payment" they expect to receive, which can also be:
-- NFTs (ERC-721, ERC-1155)
-- FTs (ERC-20)
-- Native cryptocurrency (ETH, MATIC, etc.)
CREATE TABLE IF NOT EXISTS seaport_considerations (
    -- block --
    block_num  UInt32,
    timestamp  DateTime(0, 'UTC'),

    -- transaction --
    tx_hash    FixedString(66),

    -- order fulfilled --
    order_hash FixedString(66),
    consideration_idx UInt16,

    -- consideration --
    item_type  UInt8                COMMENT 'The type of asset (NFT, FT, ETH, etc.)',
    token      FixedString(42)      COMMENT 'The contract address of the offered asset',
    token_id   UInt256              COMMENT 'The token ID for NFTs or 0 for FTs and ETH',
    amount     UInt256              COMMENT 'The amount of the offered asset',
    recipient  FixedString(42)      COMMENT 'The address that should receive the consideration',

    -- indexes (block) --
    INDEX idx_block_num     (block_num)    TYPE minmax       GRANULARITY 4,
    INDEX idx_timestamp     (timestamp)    TYPE minmax       GRANULARITY 4,

    -- indexes (transaction) --
    INDEX idx_tx_hash       (tx_hash)      TYPE bloom_filter GRANULARITY 4,

    -- indexes (order) --
    INDEX idx_order_hash    (order_hash)   TYPE bloom_filter GRANULARITY 4,

    -- indexes (consideration) --
    INDEX idx_item_type     (item_type)    TYPE minmax GRANULARITY 4,
    INDEX idx_token_id      (token_id)     TYPE minmax GRANULARITY 4,
    INDEX idx_amount        (amount)       TYPE minmax GRANULARITY 4,
    INDEX idx_recipient     (recipient)    TYPE bloom_filter GRANULARITY 4
)
ENGINE = ReplacingMergeTree()
ORDER BY (token, token_id, order_hash, consideration_idx);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_seaport_considerations
TO seaport_considerations
AS
SELECT
    order_hash,
    tx_hash,
    block_num,
    timestamp,

    row_number() OVER (PARTITION BY order_hash ORDER BY tupleElement(c, 2)) AS consideration_idx,
    tupleElement(c, 1) AS item_type,
    tupleElement(c, 2) AS token,
    tupleElement(c, 3) AS token_id,
    tupleElement(c, 4) AS amount,
    tupleElement(c, 5) AS recipient
FROM seaport_order_fulfilled
LEFT ARRAY JOIN consideration AS c;


-- Seaport Offers --
-- An offer in Seaport is the asset(s) a seller is willing to give up in exchange for the desired consideration. This can include:
-- NFTs (ERC-721, ERC-1155)
-- FTs (ERC-20)
-- Native cryptocurrency (ETH, MATIC, etc.)
CREATE TABLE IF NOT EXISTS seaport_offers (
    -- block --
    block_num  UInt32,
    timestamp  DateTime(0, 'UTC'),

    -- transaction --
    tx_hash    FixedString(66),

    -- order fulfilled --
    order_hash FixedString(66),
    offer_idx  UInt16,

    -- offer --
    item_type  UInt8                COMMENT 'The type of asset (NFT, FT, ETH, etc.)',
    token      FixedString(42)      COMMENT 'The contract address of the offered asset',
    token_id   UInt256              COMMENT 'The token ID for NFTs or 0 for FTs and ETH',
    amount     UInt256              COMMENT 'The amount of the offered asset',

    -- indexes (block) --
    INDEX idx_block_num   (block_num)   TYPE minmax       GRANULARITY 4,
    INDEX idx_timestamp   (timestamp)   TYPE minmax       GRANULARITY 4,

    -- indexes (transaction) --
    INDEX idx_tx_hash     (tx_hash)     TYPE bloom_filter GRANULARITY 4,

    -- indexes (order) --
    INDEX idx_order_hash  (order_hash)  TYPE bloom_filter GRANULARITY 4,

    -- indexes (offer) --
    INDEX idx_item_type   (item_type)   TYPE minmax       GRANULARITY 1,
    INDEX idx_token_id    (token_id)    TYPE bloom_filter GRANULARITY 4,
    INDEX idx_amount      (amount)      TYPE minmax       GRANULARITY 4
)
ENGINE = ReplacingMergeTree()
ORDER BY (token, token_id, order_hash, offer_idx);   -- cluster by the fields people filter on

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_seaport_offers
TO seaport_offers
AS
SELECT
    order_hash,
    tx_hash,
    block_num,
    timestamp,

    -- enumerate positions so we can keep the original order if needed
    row_number() OVER (PARTITION BY order_hash ORDER BY tupleElement(o, 2)) AS offer_idx,
    tupleElement(o, 1) AS item_type,
    tupleElement(o, 2) AS token,
    tupleElement(o, 3) AS token_id,
    tupleElement(o, 4) AS amount
FROM seaport_order_fulfilled
LEFT ARRAY JOIN offer AS o
-- ERC721 and ERC1155 --
WHERE item_type IN (2, 3);


CREATE TABLE IF NOT EXISTS seaport_orders_ohlc (
    -- beginning of the 1-hour bar (UTC) --
    timestamp               DateTime(0, 'UTC'),

    -- offer --
    offer_token             FixedString(42),
    offer_token_id          UInt256,

    -- consideration --
    consideration_token     FixedString(42),

    -- OHLC price per unit of consideration token --
    open                    AggregateFunction(argMin, Float64, UInt32),
    quantile                AggregateFunction(quantileDeterministic, Float64, UInt32),
    close                   AggregateFunction(argMax,  Float64, UInt32),

    -- volume --
    offer_volume            SimpleAggregateFunction(sum, UInt256) COMMENT 'gross offer volume in the window',
    consideration_volume    SimpleAggregateFunction(sum, UInt256) COMMENT 'gross offer volume in the window',

    -- universal --
    uaw                     AggregateFunction(uniq, FixedString(42)) COMMENT 'unique wallet addresses in the window',
    transactions            SimpleAggregateFunction(sum, UInt64) COMMENT 'number of transactions in the window'
)
ENGINE = AggregatingMergeTree
ORDER BY (offer_token, offer_token_id, consideration_token, timestamp);

/* one-time DDL -----------------------------------------------------------*/
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_seaport_orders_ohlc
TO seaport_orders_ohlc
AS
/* ─────────────────────────── 1-hour bar  ───────────────────────────────*/
SELECT
    toStartOfHour(timestamp)                                  AS timestamp,

    /* key dimensions: NFT + payment token ------------------------------*/
    offer_token,
    offer_token_id,
    consideration_token,

    /* price per **single** NFT unit (ERC-1155 amount handled) ----------*/
    argMinState(price_unit_wei, block_num)                     AS open,
    quantileDeterministicState(price_unit_wei, block_num)      AS quantile,
    argMaxState(price_unit_wei, block_num)                     AS close,

    /* gross volume in native token units -------------------------------*/
    sum(offer_amount)                                          AS offer_volume,
    sum(consideration_amount)                                  AS consideration_volume,

    /* unique wallets in bar  (recipient side — adjust if you add maker) */
    uniqState(offerer)                                        AS uaw,

    /* simple trade counter (one row == one NFT × consideration leg) ----*/
    sum(1)                                                    AS transactions
FROM
(
    SELECT
        any(block_num) as block_num,
        any(timestamp) as timestamp,
        any(tx_hash) as tx_hash,
        order_hash,
        offer_token,
        offer_token_id,
        sum(offer_amount) / count() AS offer_amount, -- includes duplicate `offer_amount`, need to divide by total considerations
        any(offerer) as offerer,
        consideration_token,
        sum(consideration_amount) AS consideration_amount,
        toFloat64(consideration_amount / 10e18) / toFloat64(offer_amount) AS price_unit_wei -- Price of Unit as Wei
    FROM seaport_orders
    GROUP BY order_hash, offer_token, offer_token_id, consideration_token
)
GROUP BY
    offer_token,
    offer_token_id,
    consideration_token,
    timestamp;


