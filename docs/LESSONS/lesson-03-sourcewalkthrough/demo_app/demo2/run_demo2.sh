#!/usr/bin/env bash
set -euo pipefail

# Set CGO flags required to build frankenphp (PHP headers & libraries)
export CGO_CFLAGS="-I/usr/local/include/php -I/usr/local/include/php/main -I/usr/local/include/php/TSRM -I/usr/local/include/php/Zend -I/usr/local/include/php/ext -I/usr/local/include/php/ext/date/lib -ggdb3"
export CGO_LDFLAGS="-L/usr/local/lib"

echo "Building and running demo2 with CGO flags..."
cd "$(dirname "$0")"

# Use repository go.work (parent) so the local github.com/dunglas/frankenphp module is used.
# go run .

go build -o demo2 . && ./demo2