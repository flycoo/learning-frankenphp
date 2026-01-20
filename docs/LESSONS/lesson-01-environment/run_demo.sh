#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Run demo: stop -> start (testdata as root) -> verify"

bash "$SCRIPT_DIR/stop_frankenphp.sh"
sleep 1
bash "$SCRIPT_DIR/start_frankenphp_testdata.sh"
echo "Waiting 2s for server to start..."
sleep 2
bash "$SCRIPT_DIR/verify_phpinfo.sh"
