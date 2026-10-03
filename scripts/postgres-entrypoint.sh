#!/usr/bin/env bash
set -euo pipefail

# CNPG operand images intentionally do not have docker-library's init entrypoint.
# This wrapper is only for standalone development and isolated CI databases.
if [ "$(id -u)" = 0 ]; then
  install -d -m 0700 -o postgres -g postgres "$PGDATA"
  exec runuser -u postgres -- /bin/bash "$0"
fi

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  umask 077
  password_file=$(mktemp)
  trap 'rm -f "$password_file"' EXIT
  printf '%s\n' "$POSTGRES_PASSWORD" > "$password_file"
  initdb --pgdata="$PGDATA" --username="$POSTGRES_USER" --pwfile="$password_file" \
    --auth-host=scram-sha-256 --auth-local=trust --encoding=UTF8 --locale=C.UTF-8
  rm -f "$password_file"
  trap - EXIT
fi

# Apple Container's host port forward arrives from its private VM network.
# Every TCP client must authenticate; only the container's Unix socket trusts.
printf '%s\n' 'local all all trust' 'host all all 0.0.0.0/0 scram-sha-256' \
  'host all all ::/0 scram-sha-256' > "$PGDATA/pg_hba.conf"

exec postgres -D "$PGDATA" -c listen_addresses='*' -c password_encryption=scram-sha-256 \
  -c max_connections=100
