#!/bin/sh
set -e
DIR=$(cd "$(dirname "$0")" && pwd)
cd "$DIR"
echo "Building demo binaries in $DIR"

for sub in bulk ext; do
	BINARY="$sub"
	OUTPATH="$DIR/$sub/$BINARY"
	echo "Building $BINARY (./$sub) -> $OUTPATH"
	go build -o "$OUTPATH" "./$sub"
	echo "Built: $OUTPATH"
done

echo "Running bulk..."
"$DIR/bulk/bulk"
echo
echo "Running ext..."
"$DIR/ext/ext"
