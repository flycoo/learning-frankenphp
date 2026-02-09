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

# Also stop any dlv processes
echo "Stopping any running dlv instances..."
DLV_PIDS=$(pgrep -f "dlv exec.*frankenphp" || true)
if [ -n "$DLV_PIDS" ]; then
  echo "Killing dlv: $DLV_PIDS"
  kill $DLV_PIDS || true
  sleep 1
fi

echo "Done."
