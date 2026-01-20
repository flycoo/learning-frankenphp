#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Starting frankenphp with document root set to frankenphp/testdata..."
cd "$ROOT_DIR/frankenphp/testdata"

# Run binary from build location; log to /tmp/frankenphp.log and save pid
"$ROOT_DIR/frankenphp/caddy/frankenphp/frankenphp" run --config Caddyfile > /tmp/frankenphp.log 2>&1 &
PID=$!
echo $PID > /tmp/frankenphp.pid
echo "Started frankenphp (pid=$PID), logs: /tmp/frankenphp.log"
