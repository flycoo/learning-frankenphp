#!/bin/sh
set -e
DIR=$(cd "$(dirname "$0")" && pwd)
cd "$DIR"
BINARY=$(basename "$DIR")
echo "Building $BINARY in $DIR"
go build -o "$BINARY" .

echo "Built: $DIR/$BINARY"

echo "Running $BINARY..."
"$DIR/$BINARY"
