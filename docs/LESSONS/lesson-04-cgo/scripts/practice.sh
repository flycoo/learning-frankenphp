#!/bin/sh
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

echo "Selecting a demo at random to build and run..."

TMP=$(mktemp)
for d in "$ROOT"/demo*; do
  [ -d "$d" ] || continue
  echo "$d" >> "$TMP"
done

COUNT=$(wc -l < "$TMP" | tr -d ' ')
if [ "$COUNT" -eq 0 ]; then
  echo "No demo directories found under $ROOT"
  rm -f "$TMP"
  exit 1
fi

IDX=$(( $(date +%s) % COUNT ))
CHOICE=$(sed -n "$((IDX+1))p" "$TMP")
rm -f "$TMP"

echo "Chosen demo: $CHOICE"
if [ -f "$CHOICE/build.sh" ]; then
  (cd "$CHOICE" && sh build.sh)
else
  echo "No build.sh or it's not executable in $CHOICE"
  exit 1
fi
