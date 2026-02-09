#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo "Lesson 02 - Debugging FrankenPHP"
echo "========================================="
echo ""
echo "Run demo: stop -> start -> verify"
echo ""

# Stop any running instances
bash "$SCRIPT_DIR/stop_frankenphp.sh"
echo ""

# Wait a moment
sleep 1

# Start FrankenPHP (normal mode)
bash "$SCRIPT_DIR/start_frankenphp.sh"
echo ""

# Wait for server to start
echo "Waiting 3 seconds for server to start..."
sleep 3
echo ""

# Verify the server is working
bash "$SCRIPT_DIR/verify_phpinfo.sh"
echo ""

echo "========================================="
echo "Demo completed successfully!"
echo "========================================="
echo ""
echo "To run in debug mode instead, use:"
echo "  bash $SCRIPT_DIR/start_frankenphp_debug.sh"
echo ""
echo "Then attach debugger from VS Code using 'Attach to frankenphp (Delve)' configuration"
