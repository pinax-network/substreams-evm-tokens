CREATE TABLE IF NOT EXISTS verified_tokens  (
    network              LowCardinality(String),
    contract             FixedString(42),
    description          String,
    type                 Enum8('USD' = 1, 'ETH' = 2, 'BTC' = 3, 'BNB' = 4, 'POL' = 5, 'AVAX' = 6, 'ARB' = 7, 'TRX' = 8)
)
ENGINE = ReplacingMergeTree
ORDER BY (contract, network);

-- Insert initial Stable Tokens (1:1 USD) verified tokens
INSERT INTO verified_tokens (network, contract, description, type) VALUES
    ('mainnet', lower('0xdac17f958d2ee523a2206206994597c13d831ec7'), 'USDT (Tether USD)', 'USD'),
    ('mainnet', lower('0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'), 'USDC (Circle: USDC Token)', 'USD'),
    ('mainnet', lower('0x6b175474e89094c44da98b954eedeac495271d0f'), 'DAI (Sky: Dai Stablecoin)', 'USD'),
    ('mainnet', lower('0xc5f0f7b66764f6ec8c8dff7ba683102295e16409'), 'FDUSD (First Digital USD)', 'USD'),
    ('mainnet', lower('0x0000000000085d4780b73119b644ae5ecd22b376'), 'TUSD (TrueUSD)', 'USD'),
    ('mainnet', lower('0x8e870d67f660d95d5be530380d0ec0bd388289e1'), 'USDP (Pax Dollar)', 'USD'),
    ('bsc', lower('0x55d398326f99059ff775485246999027b3197955'), 'USDT (Binance-Peg Tether USD)', 'USD'),
    ('bsc', lower('0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d'), 'USDC (Binance-Peg USDC Token)', 'USD'),
    ('bsc', lower('0x1af3f329e8be154074d8769d1ffa4ee058b1dbc3'), 'DAI (Binance-Peg Dai Stablecoin)', 'USD'),
    ('bsc', lower('0xe9e7cea3dedca5984780bafc599bd69add087d56'), 'BUSD (Binance-Peg BUSD Token)', 'USD'),
    ('base', lower('0x833589fcd6edb6e08f4c7c32d4f71b54bda02913'), 'USDC (Circle: USDC Token)', 'USD'),
    ('base', lower('0x820c137fa70c8691f0e44dc420a5e53c168921dc'), 'USDS (Sky: Dai Stablecoin)', 'USD'),
    ('base', lower('0x50c5725949a6f0c72e6c4a641f24049a917db0cb'), 'DAI (Sky: Dai Stablecoin)', 'USD'),
    ('arbone', lower('0xfd086bc7cd5c481dcc9c85ebe478a1c0b69fcbb9'), 'USDT (Tether USD)', 'USD'),
    ('arbone', lower('0xaf88d065e77c8cc2239327c5edb3a432268e5831'), 'USDC (Circle: USDC Token)', 'USD'),
    ('arbone', lower('0xff970a61a04b1ca14834a43f5de4533ebddb5cc8'), 'USDC.e (Bridged from Ethereum)', 'USD'),
    ('arbone', lower('0x6491c05a82219b8d1479057361ff1654749b876b'), 'USDS (Sky: Dai Stablecoin)', 'USD'),
    ('arbone', lower('0xda10009cbd5d07dd0cecc66161fc93d7c9000da1'), 'DAI (Sky: Dai Stablecoin)', 'USD'),
    ('optimism', lower('0x94b008aa00579c1307b0ef2c499ad98a8ce58e58'), 'USDT (Tether USD)', 'USD'),
    ('optimism', lower('0x0b2c639c533813f4aa9d7837caf62653d097ff85'), 'UDSC (Bridged via Circle CCTP)', 'USD'),
    ('optimism', lower('0x7f5c764cbc14f9669b88837ca1490cca17c31607'), 'USDC.e (Bridged from Ethereum)', 'USD'),
    ('optimism', lower('0xda10009cbd5d07dd0cecc66161fc93d7c9000da1'), 'DAI (Sky: Dai Stablecoin)', 'USD'),
    ('polygon', lower('0xc2132d05d31c914a87c6611c10748aeb04b58e8f'), 'USDT (Bridged via Polygon POS)', 'USD'),
    ('polygon', lower('0x3c499c542cef5e3811e1192ce70d8cc03d5c3359'), 'USDC (Circle: USDC Token)', 'USD'),
    ('polygon', lower('0x2791bca1f2de4661ed88a30c99a7a9449aa84174'), 'USDC (Bridged via Polygon POS)', 'USD'),
    ('polygon', lower('0x9c9e5fd8bbc25984b178fdce6117defa39d2db39'), 'BUSD (Binance-Peg BUSD Token)', 'USD'),
    ('polygon', lower('0x8f3cf7ad23cd3cadbd9735aff958023239c6a063'), 'DAI', 'USD'),
    ('unichain', lower('0x078d782b760474a361dda0af3839290b0ef57ad6'), 'USDC', 'USD'),
    ('unichain', lower('0x9151434b16b9763660705744891fA906F660EcC5'), 'USDT0 Tether USD', 'USD')
    ('avalanche', lower('0x9702230A8Ea53601f5cD2dc00fDBc13d4dF4A8c7'), 'USDT (Tether USD)', 'USD'),
    ('avalanche', lower('0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E'), 'USDC (Circle: USDC Token)', 'USD');

-- Insert initial Wrapped/Native Tokens (1:1 Native) verified tokens
INSERT INTO verified_tokens (network, contract, description, type) VALUES
    ('mainnet', lower('0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'), 'WETH (Wrapped Ether)', 'ETH'),
    ('mainnet', lower('0xB8c77482e45F1F44dE1745F52C74426C631bDD52'), 'BNB (Wrapped BNB)', 'BNB'),
    ('mainnet', lower('0x2260fac5e5542a773aa44fbcfedf7c193bc2c599'), 'WBTC (Wrapped BTC)', 'BTC'),
    ('mainnet', lower('0xcbb7c0000ab88b473b1f5afd9ef808440eed33bf'), 'cbBTC (Coinbase Wrapped BTC)', 'BTC'),
    ('mainnet', lower('0x455e53CBB86018Ac2B8092FdCd39d8444aFFC3F6'), 'Polygon Ecosystem Token', 'POL'),
    ('mainnet', lower('0xB50721BCf8d664c30412Cfbc6cf7a15145234ad1'), 'Arbitrum', 'ARB'),
    ('arbone', lower('0x82af49447d8a07e3bd95bd0d56f35241523fbab1'), 'WETH (Wrapped Ether)', 'ETH'),
    ('arbone', lower('0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f'), 'WBTC (Wrapped BTC)', 'BTC'),
    ('arbone', lower('0xcbb7c0000ab88b473b1f5afd9ef808440eed33bf'), 'cbBTC (Coinbase Wrapped BTC)', 'BTC'),
    ('arbone', lower('0x912ce59144191c1204e64559fe8253a0e49e6548'), 'Arbitrum', 'ARB'),
    ('bsc', lower('0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c'), 'WBNB (Wrapped BNB)', 'BNB'),
    ('bsc', lower('0x2170ed0880ac9a755fd29b2688956bd959f933f8'), 'WETH (Wrapped ETH)', 'ETH'),
    ('bsc', lower('0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c'), 'Binance-Peg BTCB Token', 'BTC'),
    ('bsc', lower('0x0555E30da8f98308EdB960aa94C0Db47230d2B9c'), 'WBTC (Wrapped BTC)', 'BTC'),
    ('bsc', lower('0xce7de646e7208a4ef112cb6ed5038fa6cc6b12e3'), 'Tron', 'TRX'),
    ('polygon', lower('0x7ceb23fd6bc0add59e62ac25578270cff1b9f619'), 'WETH (Wrapped Ether)', 'ETH'),
    ('polygon', lower('0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270'), 'WPOL (Wrapped Polygon)', 'POL'),
    ('polygon', lower('0x0000000000000000000000000000000000001010'), 'POL', 'POL'),
    ('polygon', lower('0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6'), 'WBTC (Wrapped BTC)', 'POL'),
    ('base', lower('0x4200000000000000000000000000000000000006'), 'WETH (Wrapped Ether)', 'ETH'),
    ('optimism', lower('0x4200000000000000000000000000000000000006'), 'WETH (Wrapped Ether)', 'ETH'),
    ('unichain', lower('0x4200000000000000000000000000000000000006'), 'WETH (Wrapped Ether)', 'ETH'),
    ('avalanche', lower('0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7'), 'WAVAX (Wrapped AVAX)', 'AVAX')
    ('avalanche', lower('0x49D5c2BdFfac6CE2BFdB6640F4F80f226bc10bAB'), 'WETH.e (Avalanche Bridge)', 'ETH')
    ('avalanche', lower('0x152b9d0FdC40C096757F570A51E494bd4b943E50'), 'BTC.b (Avalanche Bridge)', 'BTC');
