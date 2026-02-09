#!/usr/bin/env bash
# Show VS Code specific warning for Go package issues
# Called by devcontainer setup to inform user about potential warnings

# ANSI color variables (TTY only; safe for sh/bash)
if [ -t 1 ]; then
    RED="$(printf '\033[1;31m')"
    GREEN="$(printf '\033[1;31m')"
    RESET="$(printf '\033[0m')"
else
    RED=""
    GREEN=""
    RESET=""
fi

echo
printf '%s\n' "${RED}==============================================${RESET}"
printf '%s\n' "${GREEN}重要：如果 VS Code 仍显示 GO package 相关的警告，${RESET}"
printf '%s\n' "${GREEN}请执行 'Reload Window'（重新加载窗口）以清除这些警告。${RESET}"
printf '%s\n' "${GREEN}需要 Reload Window 才能消失警告${RESET}"
printf '%s\n' "${RED}==============================================${RESET}"
echo
