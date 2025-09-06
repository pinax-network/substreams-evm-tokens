CREATE TABLE IF NOT EXISTS ens (
    -- ordering --
    node                FixedString(66),
    global_sequence     UInt64,

    -- addresses --
    address             FixedString(42),

    -- names --
    name                String,
    registered          DateTime('UTC', 0),
    expires             DateTime('UTC', 0),

    -- records --
    records             Array(Tuple(String, String)),
)
ENGINE = ReplacingMergeTree(global_sequence)
ORDER BY (address, name);

-- FROM addresses --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ens_from_addresses
REFRESH EVERY 10 MINUTE
TO ens
AS
SELECT
    -- ordering --
    a.node as node,
    max(a.global_sequence) AS global_sequence,

    -- addresses --
    any(a.address) as address,

    -- names --
    any(n.name) as name,
    min(e.registered) as registered,
    max(e.expires) as expires,

    -- records --
    groupArrayMerge(r.kv_state) AS records

FROM addresses AS a
LEFT JOIN names AS n USING (node)
LEFT JOIN expires AS e USING (node)
LEFT JOIN records_by_node AS r USING (node)
GROUP BY
    a.node;
