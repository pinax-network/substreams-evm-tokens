# EAS Attestions: `Clickhouse`

## Quickstart

**Install [`substreams-sink-sql`](https://github.com/streamingfast/substreams-sink-sql)**

```bash
brew install streamingfast/tap/substreams-sink-sql
```

### Setup SQL tables in Clickhouse

```bash
substreams-sink-sql setup clickhouse://default:default@localhost:9000/eas substreams.yaml
```

### Load Clickhouse data from Substreams

```bash
substreams-sink-sql run clickhouse://default:default@localhost:9000/eas substreams.yaml \
    -e base.substreams.pinax.network:443 10000000:
```

### Perform SQL query with Clickhouse

```sql
-- Select all transactions from block 123456
SELECT
    *
FROM eas
WHERE block_num = 123456;
```
