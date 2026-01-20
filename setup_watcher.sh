#!/bin/bash
set -e

echo "=== Setting up Watcher (Dependency) ==="

# 1. Fork watcher using gh
if command -v gh &> /dev/null; then
    echo "Forking e-dant/watcher..."
    gh repo fork e-dant/watcher --remote=false --clone=false || echo "Fork might already exist."
else
    echo "Warning: 'gh' not found. Please fork e-dant/watcher manually if you haven't already."
fi

GITHUB_USER="flycoo" # Assumed or detected
if command -v gh &> /dev/null; then
    GITHUB_USER=$(gh api user -q .login)
fi

USER_FORK_URL="https://github.com/$GITHUB_USER/watcher.git"
OFFICIAL_URL="https://github.com/e-dant/watcher.git"

# 2. Configure Directory
cd /workspaces/gophp/watcher

echo "Configuring remotes for watcher..."
# Rename current origin to upstream if it points to official
CURRENT_ORIGIN=$(git remote get-url origin)
if [[ "$CURRENT_ORIGIN" == *"e-dant/watcher"* ]]; then
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
if [ -d "watcher/.git" ]; then
    echo "Registering watcher as submodule..."
    
    if grep -q "watcher" .gitmodules; then
        echo "Already in .gitmodules"
    else
        cat >> .gitmodules <<EOF
[submodule "watcher"]
	path = watcher
	url = $USER_FORK_URL
EOF
    fi
    
    # Add to git index
    git add watcher .gitmodules
fi

echo "Watcher setup complete."
