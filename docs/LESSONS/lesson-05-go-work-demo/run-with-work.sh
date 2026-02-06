#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Running with local go.work (uses ./localdep)"
go run ./consumer
