-- Search Uniswap V2 contracts ordered by largest USDT holders --
SELECT
    factory.address as address,
    (b.new_balance / Pow(10, contracts.decimals)) as amount -- USDT has 6 decimals
FROM (
    SELECT
        c.address as address
    FROM contracts c
    JOIN contract_creations cc
        ON c.address = cc.address
    WHERE c.symbol = 'UNI-V2' AND cc.to = '0x7a250d5630b4cf539739df2c5dacb4c659f2488d' -- Uniswap V2 Factory
    ORDER BY timestamp DESC
) factory
JOIN balances b FINAL
    ON b.owner = factory.address
JOIN contracts
    ON b.contract = contracts.address
WHERE b.contract = '0xdac17f958d2ee523a2206206994597c13d831ec7' -- Tether USDT
ORDER BY amount DESC
LIMIT 50