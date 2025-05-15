-- Search Uniswap V2 factor addresses --
SELECT
    c.address as address
FROM contracts c
JOIN contract_creations cc
    ON c.address = cc.address
WHERE c.symbol = 'UNI-V2' AND cc.to = '0x7a250d5630b4cf539739df2c5dacb4c659f2488d'
ORDER BY timestamp DESC