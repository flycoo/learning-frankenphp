#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Starting frankenphp under Delve (headless) for debugging..."
cd "$ROOT_DIR"

# Start dlv with headless mode, listening on port 2345
dlv exec "$ROOT_DIR/frankenphp/caddy/frankenphp/frankenphp" --headless --listen=:2345 --api-version=2 -- run --config "$SCRIPT_DIR/Caddyfile" > /tmp/frankenphp-lesson02-debug.log 2>&1 &
PID=$!
echo $PID > /tmp/frankenphp-lesson02-debug.pid
echo "Started frankenphp under Delve (pid=$PID), logs: /tmp/frankenphp-lesson02-debug.log"
echo "Delve listening on: 127.0.0.1:2345"
echo "Document root: $SCRIPT_DIR"
echo ""
echo "To attach debugger, use VS Code 'Attach to frankenphp (Delve)' configuration"
