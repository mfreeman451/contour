#!/usr/bin/env bash
# Sourced by the Bazel integration target; PostgreSQL is private to this test action.
set -euo pipefail
fixture_root=$(mktemp -d /tmp/contour-pg.XXXXXXXX)
tar -xzf ../../build/postgres.tar.gz -C "$fixture_root"
mkdir "$fixture_root/socket"
chmod 0755 "$fixture_root"
fixture_user=()
if [ "$(id -u)" = 0 ]; then
  chown -R nobody:nogroup "$fixture_root"
  fixture_user=(/usr/sbin/runuser -u nobody --)
fi
fixture_cleanup() {
  "${fixture_user[@]}" "$fixture_root/bin/pg_ctl" -D "$fixture_root/data" stop -m immediate >/dev/null 2>&1 || true
  rm -rf "$fixture_root"
}
trap fixture_cleanup EXIT
"${fixture_user[@]}" "$fixture_root/bin/initdb" -D "$fixture_root/data" --username=contour --auth=trust --no-locale >/dev/null
"${fixture_user[@]}" "$fixture_root/bin/pg_ctl" -D "$fixture_root/data" -l "$fixture_root/postgres.log" \
  -o "-c listen_addresses='' -c unix_socket_directories='$fixture_root/socket' -c max_connections=100" -w start >/dev/null
"${fixture_user[@]}" "$fixture_root/bin/createdb" -h "$fixture_root/socket" -U contour contour_test
export DATABASE_USER=contour DATABASE_PORT=5432 DATABASE_SOCKET_DIR="$fixture_root/socket"
