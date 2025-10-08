-- List top 100 protocols by swap count in 2025
SELECT
    factory,
    protocol,
    count()
FROM swaps
INNER JOIN pools USING (pool)
WHERE toYear(timestamp) = 2025
GROUP BY
    factory,
    protocol
ORDER BY count() DESC
LIMIT 100
