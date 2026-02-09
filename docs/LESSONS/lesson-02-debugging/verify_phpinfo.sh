#!/usr/bin/env bash
set -euo pipefail

echo "Requesting /phpinfo.php to verify the server..."
echo "========================================"
curl -sS http://127.0.0.1:80/phpinfo.php | head -n 60
echo ""
echo "========================================"
echo "Server is responding correctly!"
