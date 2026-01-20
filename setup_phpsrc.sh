#!/bin/bash
set -e

echo "=== Setting up PHP-SRC ==="

# 1. Fork php-src using gh
if command -v gh &> /dev/null; then
    echo "Forking php/php-src..."
    gh repo fork php/php-src --remote=false --clone=false || echo "Fork might already exist."
else
    echo "Warning: 'gh' not found. Please fork php/php-src manually if you haven't already."
fi

GITHUB_USER="flycoo" # Assumed or detected
if command -v gh &> /dev/null; then
    GITHUB_USER=$(gh api user -q .login)
fi

USER_FORK_URL="https://github.com/$GITHUB_USER/php-src.git"
OFFICIAL_URL="https://github.com/php/php-src.git"

# 2. Configure Directory
cd /workspaces/gophp/php-src

echo "Configuring remotes for php-src..."
# Rename current origin to upstream if it points to official
CURRENT_ORIGIN=$(git remote get-url origin)
if [[ "$CURRENT_ORIGIN" == *"php/php-src"* ]]; then
    git remote rename origin upstream || true
fi

# Add/Set origin to user fork
if git remote | grep -q "origin"; then
    git remote set-url origin "$USER_FORK_URL"
else
    git remote add origin "$USER_FORK_URL"
fi

# Ensure upstream exists
if ! git remote | grep -q "upstream"; then
    git remote add upstream "$OFFICIAL_URL"
fi

echo "Remotes configured:"
git remote -v

# 3. Add as submodule to root
cd /workspaces/gophp

# If it's already a git repo inside, we need to register it as a submodule
if [ -d "php-src/.git" ]; then
    echo "Registering php-src as submodule..."
    # 'git submodule add' might fail if the folder exists and is already a repo but not indexed.
    # We force add it to .gitmodules if needed, or just let git add handle insertion into index.
    
    if grep -q "php-src" .gitmodules; then
        echo "Already in .gitmodules"
    else
        cat >> .gitmodules <<EOF
[submodule "php-src"]
	path = php-src
	url = $USER_FORK_URL
EOF
    fi
    
    # Add to git index
    git add php-src .gitmodules
fi

echo "PHP-SRC setup complete."
