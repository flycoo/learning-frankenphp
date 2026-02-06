#!/bin/bash
set -e

# Run the CGO demo: builds and runs the demo/main.go which calls a C function.
ROOT_DIR="$(dirname "$0")"
DEMO_DIR="$ROOT_DIR/demo"

echo "Building and running CGO demo in $DEMO_DIR"
cd "$DEMO_DIR"

echo "Running demo: bulk callback"
go run main.go

echo
echo "Running extended demo: C allocated string -> Go reads and frees"
go run ext.go
