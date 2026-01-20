#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "Stopping any running frankenphp instances..."
PIDS=$(pgrep -f "${ROOT_DIR}/frankenphp/caddy/frankenphp/frankenphp" || true)
if [ -n "$PIDS" ]; then
  echo "Killing: $PIDS"
  kill $PIDS || true
  sleep 1
else
  echo "No frankenphp processes found."
fi

echo "Done."
