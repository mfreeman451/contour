#!/usr/bin/env bash
# Sourced by the local and Bazel multi-node integration workflows.
tls_root=${TEST_TMPDIR:-$PWD/.local}
mkdir -p "$tls_root"
tls_dir=$(mktemp -d "$tls_root/cluster-tls.XXXXXXXX")
trap 'rm -rf "$tls_dir"' EXIT
openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes -days 1 \
  -subj /CN=contour-ca -addext basicConstraints=critical,CA:TRUE -addext keyUsage=critical,keyCertSign,cRLSign \
  -keyout "$tls_dir/ca-key.pem" -out "$tls_dir/ca.pem" >/dev/null 2>&1
openssl req -new -newkey ec -pkeyopt ec_paramgen_curve:P-256 -nodes -subj /CN=contour \
  -keyout "$tls_dir/key.pem" -out "$tls_dir/request.pem" >/dev/null 2>&1
printf '%s\n' 'subjectAltName=DNS:contour,DNS:contour-discovery' 'extendedKeyUsage=serverAuth,clientAuth' > "$tls_dir/extensions"
openssl x509 -req -in "$tls_dir/request.pem" -CA "$tls_dir/ca.pem" -CAkey "$tls_dir/ca-key.pem" \
  -CAcreateserial -days 1 -extfile "$tls_dir/extensions" -out "$tls_dir/cert.pem" >/dev/null 2>&1
chmod 0600 "$tls_dir/key.pem" "$tls_dir/ca-key.pem"
cat > "$tls_dir/options.conf" <<EOF
[{server, [{certfile,"$tls_dir/cert.pem"},{keyfile,"$tls_dir/key.pem"},{cacertfile,"$tls_dir/ca.pem"},{verify,verify_peer},{fail_if_no_peer_cert,true}]},
 {client, [{server_name_indication,"contour"},{certfile,"$tls_dir/cert.pem"},{keyfile,"$tls_dir/key.pem"},{cacertfile,"$tls_dir/ca.pem"},{verify,verify_peer}]}].
EOF
export CLUSTER_SMOKE_TLS_FILE="$tls_dir/options.conf"
export ERL_FLAGS="${ERL_FLAGS:-} -hidden -proto_dist inet_tls -ssl_dist_optfile $tls_dir/options.conf"
epmd -daemon
