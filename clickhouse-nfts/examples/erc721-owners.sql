-- populate --
INSERT INTO erc721_transfers SELECT * FROM erc721_transfers;
OPTIMIZE TABLE erc721_transfers FINAL;

-- Owners by ERC721 Token contract --
SELECT
    owner,
    name,
    symbol,
    count()
FROM erc721_owners
JOIN erc721_metadata_by_contract using (contract)
WHERE
    owner != '0x0000000000000000000000000000000000000000' AND
    contract = '0xbbbba1ee822c9b8fc134dea6adfc26603a9cbbbb'
GROUP BY owner, name, symbol
ORDER BY count()
DESC LIMIT 10;

-- ERC721 Tokens by Owner --
SELECT
    contract,
    name,
    symbol,
    count()
FROM erc721_owners
JOIN erc721_metadata_by_contract using (contract)
WHERE
    owner == '0xeef999c151c3a51acf4cd90d5415b33ef53b3970'
GROUP BY contract, name, symbol
ORDER BY count()
DESC LIMIT 10;

-- ERC721 Token IDs by Owner --
SELECT
    contract,
    token_id,
    name,
    symbol
FROM erc721_owners
JOIN erc721_metadata_by_contract USING (contract)
WHERE owner = '0xeef999c151c3a51acf4cd90d5415b33ef53b3970'
ORDER BY timestamp DESC
LIMIT 20;
