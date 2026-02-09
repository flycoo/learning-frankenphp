#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Starting frankenphp with lesson-02-debugging Caddyfile..."
cd "$ROOT_DIR"

# Run binary from build location; log to /tmp/frankenphp-lesson02.log and save pid
"$ROOT_DIR/frankenphp/caddy/frankenphp/frankenphp" run --config "$SCRIPT_DIR/Caddyfile" > /tmp/frankenphp-lesson02.log 2>&1 &
PID=$!
echo $PID > /tmp/frankenphp-lesson02.pid
echo "Started frankenphp (pid=$PID), logs: /tmp/frankenphp-lesson02.log"
echo "Document root: $SCRIPT_DIR"
