-- populate --
INSERT INTO erc1155_transfers SELECT * FROM erc1155_transfers;
INSERT INTO erc1155_transfers SELECT * FROM erc1155_transfers;
OPTIMIZE TABLE erc1155_transfers FINAL;

-- Statistics for ERC-1155 balances --
SELECT
    contract,
    count(DISTINCT token_id) AS total_tokens,
    count(DISTINCT owner) AS total_owners
FROM erc1155_balances
GROUP BY contract
ORDER BY total_owners DESC
LIMIT 10;

-- ERC-1155 Balances by Contract & Token ID --
SELECT
    owner,
    token_id,
    balance
FROM erc1155_balances
WHERE
    owner != '0x0000000000000000000000000000000000000000' AND
    contract = '0x33fd426905f149f8376e227d0c9d3340aad17af1' AND
    token_id = 345
ORDER BY balance DESC
LIMIT 10;

-- ERC-1155 Token ID Balances by Owner --
SELECT
    contract,
    token_id,
    balance
FROM erc1155_balances
WHERE owner = '0x664e3a3a6a6fa524d06f4d612fe8440b923574bd'
ORDER BY timestamp DESC
LIMIT 20;
