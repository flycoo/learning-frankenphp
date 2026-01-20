#!/bin/bash
set -e

# Configuration
GITHUB_USER="flycoo" # Default user from your prompt
FRANKENPHP_FORK_URL="git@github.com:$GITHUB_USER/frankenphp.git"
LEARNING_REPO_URL="git@github.com:$GITHUB_USER/learning-frankenphp.git"

echo "=== Git Setup Script for FrankenPHP Learning Environment ==="
echo "Assumed GitHub User: $GITHUB_USER"
echo ""
echo "PREREQUISITES (Please do this manually on GitHub website first):"
echo "1. Fork 'php/frankenphp' (formerly dunglas/frankenphp) to your account -> $GITHUB_USER/frankenphp"
echo "2. Create a NEW empty repository named 'learning-frankenphp'"
echo ""
read -p "Have you created these repositories on GitHub? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please create them first, then run this script again."
    exit 1
fi

# 1. Handle FrankenPHP (The Source Code)
echo ">>> Configuring FrankenPHP repository..."
cd /workspaces/gophp/frankenphp

# Check for uncommitted changes and commit them
if [[ -n $(git status -s) ]]; then
    echo "Committing changes in frankenphp..."
    git add .
    git commit -m "feat: logs and tweaks for worker mode study" || echo "Nothing to commit or commit failed"
fi

# Configure remotes
echo "Configuring remotes..."
# Rename original origin to upstream if not already done
if ! git remote | grep -q "upstream"; then
    git remote rename origin upstream
fi

# Add/Update origin to point to your fork
if git remote | grep -q "origin"; then
    git remote set-url origin "$FRANKENPHP_FORK_URL"
else
    git remote add origin "$FRANKENPHP_FORK_URL"
fi

echo "FrankenPHP configured. (You can push later with 'git push -u origin')"

# 2. Handle Root Workspace (The Learning Environment: docs, .vscode)
echo ">>> Configuring Learning Workspace repository..."
cd /workspaces/gophp

if [ ! -d .git ]; then
    git init
    # Default branch name
    git branch -M main
fi

# Create .gitignore for the root repo
# We ignore the contents of frankenphp/ but we will track it as a submodule
cat > .gitignore <<EOF
/frankenphp/*
!/frankenphp/
.DS_Store
*.log
EOF

# Add frankenphp as a pseudo-submodule (since it's already there)
# We add it to the index solely to track the commit hash
git add frankenphp

# Manually create .gitmodules entry since 'git submodule add' fails on existing dirs
cat > .gitmodules <<EOF
[submodule "frankenphp"]
	path = frankenphp
	url = $FRANKENPHP_FORK_URL
EOF

git add .gitignore .gitmodules
git add docs .vscode .devcontainer

if [[ -n $(git status -s) ]]; then
    git commit -m "docs: init learning environment for frankenphp" || echo "Nothing to commit"
fi

# Add remote for the learning repo
if ! git remote | grep -q "origin"; then
    git remote add origin "$LEARNING_REPO_URL"
else
    git remote set-url origin "$LEARNING_REPO_URL"
fi

echo ""
echo "=== Setup Complete ==="
echo "Now you can run the following to push your work:"
echo ""
echo "1. Push the FrankenPHP Source changes:"
echo "   cd /workspaces/gophp/frankenphp"
echo "   git push -u origin $(git branch --show-current)"
echo ""
echo "2. Push the Learning Environment changes:"
echo "   cd /workspaces/gophp"
echo "   git push -u origin main"
