#!/bin/sh
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"
echo "Running go tests under $ROOT"
go test ./... -v
