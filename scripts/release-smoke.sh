#!/usr/bin/env bash
set -euo pipefail
release_dir=$(mktemp -d "$TEST_TMPDIR/release.XXXXXXXX")
trap 'rm -rf "$release_dir"' EXIT
archive="$TEST_SRCDIR/$TEST_WORKSPACE/elixir/contour/contour-release.tar.gz"
tar -xzf "$archive" -C "$release_dir"
export CONTOUR_ROLE=migrate DATABASE_HOST=database.invalid DATABASE_USER=fixture DATABASE_PASSWORD=fixture DATABASE_NAME=fixture
export DATABASE_CA_FILE=/etc/ssl/certs/ca-certificates.crt
"$release_dir/bin/contour" eval 'unless System.version() == "1.20.4" and :erlang.system_info(:otp_release) == ~c"29" and Code.ensure_loaded?(Contour.Release) and File.exists?(Application.app_dir(:contour, "priv/static/cache_manifest.json")), do: raise("release contract failed"); IO.puts("Packaged Elixir/ERTS and digested assets load")'
