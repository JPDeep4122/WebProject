#!/usr/bin/env bash
set -euo pipefail

SQLCMD=/opt/mssql-tools18/bin/sqlcmd

until "$SQLCMD" -C -S "$DB_HOST" -U sa -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" >/dev/null 2>&1; do
  sleep 2
done

"$SQLCMD" -C -S "$DB_HOST" -U sa -P "$MSSQL_SA_PASSWORD" \
  -Q "IF DB_ID(N'${DB_NAME}') IS NULL CREATE DATABASE [${DB_NAME}]"
