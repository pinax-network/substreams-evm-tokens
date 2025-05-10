INSERT INTO seaport_order_fulfilled SELECT * FROM seaport_order_fulfilled;
OPTIMIZE TABLE seaport_order_fulfilled FINAL;

-- confirmation --
EXPLAIN indexes = 1
SELECT *
FROM seaport_offers
WHERE token = '0x60e4d786628fea6478f785a6d7e704777c86a7c6'
LIMIT 10;

-- Seaport Top Tokens by Offers --
SELECT
    token,
    count()
FROM seaport_offers
GROUP BY token
ORDER BY count() DESC
LIMIT 10;

-- Seaport Top Tokens by Considerations --
SELECT
    token,
    count(),
    CONCAT(floor(count() / ( SELECT count() FROM seaport_considerations)* 100, 2), '%') as percentage
FROM seaport_considerations WHERE item_type IN (0, 1) AND token != ''
GROUP BY token
ORDER BY count() DESC
LIMIT 10;

-- Seaport unique Offers by Token --
SELECT DISTINCT order_hash
FROM seaport_offers
WHERE token = '0x56cc0dc0275442892fbedd408393e079f837ebba'

-- Seaport Order Fulfilled by Token --
SELECT
    timestamp,
    offerer,
    recipient,
    offer,
    consideration
FROM seaport_order_fulfilled
WHERE order_hash IN
(
    SELECT DISTINCT order_hash
    FROM seaport_considerations
    WHERE token = '0x56cc0dc0275442892fbedd408393e079f837ebba'
)
ORDER BY timestamp DESC
LIMIT 10;

-- Seaport Top Tokens by Sales --
SELECT
    s.offer_token as token,
    count() AS total_sales,
    any(m.name) AS name,
    floor(sum(consideration_amount) / pow(10, 18), 2) AS sales_in_ETH
FROM seaport_sales as s
JOIN erc721_metadata_by_contract AS m ON s.offer_token = m.contract
WHERE
    offer_item_type = 2 AND -- ERC-721
    consideration_token IN (
        '0x0000000000000000000000000000000000000000',
        '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
    ) -- ETH and WETH
GROUP BY offer_token
ORDER BY sales_in_ETH DESC
LIMIT 10;