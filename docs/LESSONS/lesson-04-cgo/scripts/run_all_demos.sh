#!/bin/sh
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

for d in "$ROOT"/demo*; do
  if [ -d "$d" ] && [ -x "$d/build.sh" ]; then
    echo "--- Running build in $d ---"
    (cd "$d" && sh build.sh)
  fi
done

echo "All demos built and run."
