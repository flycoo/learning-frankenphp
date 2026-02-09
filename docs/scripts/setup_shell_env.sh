#!/usr/bin/env bash
# Shell environment setup for FrankenPHP development
# This script creates symlink and exports environment variables

# Create gophp command symlink (requires sudo, run once on container creation)
if [ ! -L "/usr/local/bin/gophp" ]; then
    sudo ln -sf /workspaces/gophp/docs/scripts/run_with_phpenv.sh /usr/local/bin/gophp 2>/dev/null || true
fi

# Export CGO flags for manual go build/run commands
export CGO_CFLAGS="-I/usr/local/include/php -I/usr/local/include/php/main -I/usr/local/include/php/TSRM -I/usr/local/include/php/Zend -I/usr/local/include/php/ext -I/usr/local/include/php/ext/date/lib -ggdb3"
export CGO_LDFLAGS="-L/usr/local/lib"

# Add useful aliases
alias ll="ls -lah"

# Optional: print setup confirmation (comment out if too verbose)
# echo "FrankenPHP dev environment ready. Use 'gophp run|build <dir>' to compile with PHP support."