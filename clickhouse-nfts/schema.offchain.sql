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
