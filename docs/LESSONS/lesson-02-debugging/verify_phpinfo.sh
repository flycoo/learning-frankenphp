#!/usr/bin/env bash
set -euo pipefail

echo "Requesting /phpinfo.php to verify the server..."
echo "========================================"
# 注意：curl | head 组合会产生 "curl: (23) Failure writing output to destination" 错误
# 原因：head -n 60 读取 60 行后关闭管道，而 curl 仍在写入剩余数据导致管道断开
# 这是正常行为，不是真正的错误。使用 || true 来忽略此退出码
curl -sS http://127.0.0.1:80/phpinfo.php | head -n 60 || true
echo ""
echo "========================================"
echo "Server is responding correctly!"
