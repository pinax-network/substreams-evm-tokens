CREATE TABLE IF NOT EXISTS seaport_ohlc_prices (
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
    argMinState(price_unit, block_num)                        AS open,
    quantileDeterministicState(price_unit, block_num)         AS quantile,
    argMaxState(price_unit, block_num)                        AS close,

    /* gross volume in native token units -------------------------------*/
    sum(offer_amount)                                           AS offer_volume,
    sum(consideration_amount)                                   AS consideration_volume,

    /* unique wallets in bar  (recipient side — adjust if you add maker) */
    uniqState(offerer)                                        AS uaw,

    /* simple trade counter (one row == one NFT × consideration leg) ----*/
    sum(1)                                                    AS transactions
FROM
(
    /* compute per-unit price */
    SELECT
        block_num,
        timestamp,
        tx_hash,
        order_hash,
        offer_token,
        offer_token_id,
        sum(offer_amount) / count() AS offer_amount, -- includes duplicate `offer_amount`, need to divide by total considerations
        offerer,
        consideration_token,
        sum(consideration_amount) AS consideration_amount,
        /* price_unit = consideration_amount / offer_amount (float) */
        CAST(consideration_amount / pow(10, 18), 'Float64') / greatest(CAST(offer_amount, 'Float64'), 1.0) AS price_unit -- stored as Wei
    FROM seaport_orders
    WHERE tx_hash = '0x9ba074d7261acc12b9870f1951a65ab48c6b70805bbfb74e960c1b670f131234'
    GROUP BY block_num, timestamp, tx_hash, order_hash, offer_token, offer_token_id, offerer, consideration_token
)
GROUP BY
    offer_token,
    offer_token_id,
    consideration_token,
    timestamp;
