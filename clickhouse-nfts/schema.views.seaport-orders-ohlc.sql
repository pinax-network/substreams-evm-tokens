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
