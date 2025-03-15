#!/bin/bash
# init.sh - Custom ClickHouse initialization script

echo "Running ClickHouse init script..."

# Execute SQL file
clickhouse-client --multiquery < /docker-entrypoint-initdb.d/ch_init.sql

# Then start ClickHouse normally
exec /entrypoint.sh
