#!/usr/bin/env bash
set -euo pipefail

# Helper to run `go build` or `go run` with PHP CGO flags exported.
# Usage:
#   ./run_with_phpenv.sh [build|run] [dir]
# Examples:
#   ./run_with_phpenv.sh run docs/LESSONS/lesson-03-sourcewalkthrough/demo_app/demo2
#   ./run_with_phpenv.sh build frankenphp/caddy/frankenphp

CMD=${1:-run}
TARGET_DIR=${2:-.}

# Try to obtain flags from php-config if available
if command -v php-config >/dev/null 2>&1; then
    PHP_INCLUDES=$(php-config --includes 2>/dev/null || echo "")
    PHP_LDFLAGS=$(php-config --ldflags 2>/dev/null || echo "")
    # Fallback to defaults if empty
    if [ -z "$PHP_INCLUDES" ]; then
        PHP_INCLUDES="-I/usr/local/include/php -I/usr/local/include/php/main -I/usr/local/include/php/TSRM -I/usr/local/include/php/Zend -I/usr/local/include/php/ext -I/usr/local/include/php/ext/date/lib"
    fi
    if [ -z "$PHP_LDFLAGS" ]; then
        PHP_LDFLAGS="-L/usr/local/lib"
    fi
    # Always append debug flags
    PHP_INCLUDES="$PHP_INCLUDES -ggdb3"
else
    PHP_INCLUDES="-I/usr/local/include/php -I/usr/local/include/php/main -I/usr/local/include/php/TSRM -I/usr/local/include/php/Zend -I/usr/local/include/php/ext -I/usr/local/include/php/ext/date/lib -ggdb3"
    PHP_LDFLAGS="-L/usr/local/lib"
fi

export CGO_CFLAGS="${PHP_INCLUDES}"
export CGO_LDFLAGS="${PHP_LDFLAGS}"

echo "Using CGO_CFLAGS=${CGO_CFLAGS}"
echo "Using CGO_LDFLAGS=${CGO_LDFLAGS}"

pushd "$TARGET_DIR" >/dev/null
case "$CMD" in
  build)
    go build ./...
    ;;
  run)
    # run the package in the directory (must be a main package)
    go run .
    ;;
  *)
    echo "Unknown command: $CMD" >&2
    popd >/dev/null
    exit 2
    ;;
esac
popd >/dev/null
