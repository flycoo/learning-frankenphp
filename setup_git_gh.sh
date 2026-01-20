#!/bin/bash
set -e

echo "=== GitHub CLI (gh) Automated Setup ==="

# 1. Check for gh tool
if ! command -v gh &> /dev/null; then
    echo "Error: 'gh' tool is not installed."
    echo "Please install it: sudo apt install gh"
    exit 1
fi

# 2. Check authentication
if ! gh auth status &> /dev/null; then
    echo "Error: You are not logged in to GitHub."
    echo "Please run: gh auth login"
    exit 1
fi

GITHUB_USER=$(gh api user -q .login)
echo "Detected GitHub User: $GITHUB_USER"

# 3. Handle FrankenPHP Fork
echo ">>> Processing FrankenPHP submodule..."
cd /workspaces/gophp/frankenphp

# Check if fork exists, if not, fork it.
# If it exists, this command essentially ensures we have a remote pointing to it.
# --remote=true adds a git remote for the fork.
# --clone=false means don't download it again (we are in it).
echo "Forking php/frankenphp to $GITHUB_USER/frankenphp..."
gh repo fork php/frankenphp --remote=true --remote-name=origin --clone=false || echo "Fork might already exist or remote set."

echo "Note: The Frankenphp fork is kept PUBLIC."
echo "      GitHub does not allow private forks of public repositories unless you 'detach' them."
echo "      Keeping it public allows you to easily sync with upstream and submit Pull Requests."

# Ensure 'upstream' is set to the original
if ! git remote | grep -q "upstream"; then
    git remote add upstream https://github.com/php/frankenphp.git
fi

# 4. Handle Learning Repo
echo ">>> Processing Learning Repository..."
cd /workspaces/gophp

# Initialize if needed
if [ ! -d .git ]; then
    git init
    git branch -M main
    
    # Create gitignore
    cat > .gitignore <<EOF
/frankenphp/*
!/frankenphp/
.DS_Store
*.log
EOF

    # Add submodule
    git add frankenphp
    cat > .gitmodules <<EOF
[submodule "frankenphp"]
	path = frankenphp
	url = https://github.com/$GITHUB_USER/frankenphp.git
EOF
    git add .gitignore .gitmodules
    git add docs .vscode .devcontainer
    git commit -m "docs: init learning environment via gh cli"
fi

# Check if repo exists on GitHub
if gh repo view "$GITHUB_USER/learning-frankenphp" &> /dev/null; then
    echo "Repository 'learning-frankenphp' already exists."
    # Ensure remote is set
    if ! git remote | grep -q "origin"; then
        git remote add origin "https://github.com/$GITHUB_USER/learning-frankenphp.git"
    fi
else
    echo "Creating new repository 'learning-frankenphp'..."
    # Create valid remote repo
    gh repo create learning-frankenphp --private --source=. --remote=origin --push
fi

echo "=== Setup Complete! ==="
