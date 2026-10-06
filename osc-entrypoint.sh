#!/usr/bin/env bash
# OSC entrypoint for OpenFGA: PostgreSQL datastore, required preshared-key
# authentication, HTTP on $PORT. The upstream image is distroless (no shell), so
# this image copies the official binary into Alpine. OpenFGA does not migrate its
# own database, so run the schema migration before starting the server.
set -Eeuo pipefail

: "${OPENFGA_DATASTORE_URI:?OPENFGA_DATASTORE_URI (PostgreSQL URL, postgres://user:password@host:5432/db) is required}"
: "${OPENFGA_AUTHN_PRESHARED_KEYS:?OPENFGA_AUTHN_PRESHARED_KEYS (API key, comma-separated for several) is required}"

PORT="${PORT:-8080}"

export OPENFGA_DATASTORE_ENGINE=postgres
export OPENFGA_AUTHN_METHOD=preshared
export OPENFGA_HTTP_ADDR="0.0.0.0:${PORT}"
export OPENFGA_PLAYGROUND_ENABLED=false
export OPENFGA_LOG_LEVEL="${OPENFGA_LOG_LEVEL:-info}"

echo "osc-entrypoint: running database migrations"
openfga migrate --datastore-engine postgres --datastore-uri "${OPENFGA_DATASTORE_URI}"

exec openfga "${@:-run}"
