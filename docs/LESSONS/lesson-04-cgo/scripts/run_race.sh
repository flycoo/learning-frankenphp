#!/bin/sh
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
echo "Running go tests with race detector under $ROOT"
CGO_ENABLED=1 go test -race ./... -v
