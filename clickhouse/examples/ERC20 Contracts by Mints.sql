WITH all_contracts AS (
    SELECT contract, count() as transfers
    FROM erc20_transfers
    GROUP BY contract
),
mints AS (
    SELECT contract, count(*) as mints
    FROM erc20_transfers
    WHERE "from" = '0x0000000000000000000000000000000000000000' OR `from` = contract
    GROUP BY contract
)
SELECT
    ac.contract,
    c.name,
    c.symbol,
    m.mints,
    ac.transfers
FROM
    all_contracts ac
    LEFT JOIN contracts c ON ac.contract = c.address
    LEFT JOIN mints m ON ac.contract = m.contract
WHERE m.mints = 0
ORDER BY
    ac.transfers DESC
LIMIT
    200;
