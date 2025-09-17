/* ===========================
   ONE-TIME INSERT: Native asset
   =========================== */
INSERT INTO metadata_initialize (contract, symbol, name, decimals, block_num, block_hash, timestamp)
VALUES ('0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee', 'Native', 'Native', 18, toUInt64(0), '', toDateTime(0, 'UTC'));