#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Running without go.work (GOWORK=off)"
GOWORK=off go run ./consumer
