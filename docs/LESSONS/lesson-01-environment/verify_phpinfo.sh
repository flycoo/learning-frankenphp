#!/usr/bin/env bash
set -euo pipefail

echo "Requesting /phpinfo.php to verify the server..."
curl -sS http://127.0.0.1:80/phpinfo.php | head -n 60
