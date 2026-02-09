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

# Final prominent reminder for the user (colored)
# Using Red (\033[31m) and Green (\033[32m) to ensure visibility
echo
printf "\033[1;31m==============================================\033[0m\n"
printf "\033[1;31m重要：如果 VS Code 仍显示 GO package 相关的警告，\033[0m\n"
printf "\033[1;31m请执行 'Reload Window'（重新加载窗口）以清除这些警告。\033[0m\n"
printf "\033[1;31m需要 Reload Window 才能消失警告\033[0m\n"
printf "\033[1;31m==============================================\033[0m\n"
echo

printf "\033[1;31mColor Test\033[0m\n"