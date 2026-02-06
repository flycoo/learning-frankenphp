#!/bin/bash
set -e

# Run the CGO demo: builds and runs the demo/main.go which calls a C function.
ROOT_DIR="$(dirname "$0")"
DEMO_DIR="$ROOT_DIR/demo"

echo "Building and running CGO demo in $DEMO_DIR"
cd "$DEMO_DIR"

# Debug controls:
# - pass argument "debug" or set DEBUG_BUILD=1 to run `go run -x` (prints gcc/ld commands)
# - set WORK=1 to run `go build -work` before running (shows temp work dir from Go tool)
DO_DEBUG=0
if [ "$1" = "debug" ] || [ "${DEBUG_BUILD:-0}" = "1" ]; then
	DO_DEBUG=1
fi

if [ "${WORK:-${BUILD_WORK:-0}}" = "1" ]; then
	echo "Running go build -work to show temporary work directory (CGO artifacts preserved)"
	go build -work main.go || true
fi

if [ "$DO_DEBUG" = "1" ]; then
	echo "Running bulk demo (debug, verbose cgo)"
	go run -x ./bulk
else
	echo "Running bulk demo"
	go run ./bulk
fi

echo
if [ "$DO_DEBUG" = "1" ]; then
	echo "Running ext demo (debug, verbose cgo)"
	go run -x ./ext
else
	echo "Running ext demo"
	go run ./ext
fi

