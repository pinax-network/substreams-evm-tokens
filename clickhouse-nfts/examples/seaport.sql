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
FROM seaport_order_fulfilled AS f
WHERE f.order_hash IN
(
    SELECT DISTINCT order_hash
    FROM seaport_considerations
    WHERE token = '0x56cc0dc0275442892fbedd408393e079f837ebba'
)
ORDER BY timestamp DESC
LIMIT 10;