#!/bin/bash
set -e

echo "=== Committing Changes ==="

# 1. Setup Root .gitignore properly
echo ">>> Updating .gitignore..."
cat > .gitignore <<EOF
# IDE / Editor
.DS_Store
.vscode/*
!.vscode/launch.json
!.vscode/tasks.json
!.vscode/extensions.json
!/.vscode/*.json

# Dependency / Build
php-src/
go.work
go.work.sum
*.log
*.test
test_bin
test_server
dist/
/jdk/

# Submodule - Ignore content but keep the folder (managed by git submodule)
# Note: standard git submodule handling doesn't need explicit excludes usually,
# but since we had that before, let's keep it clean:
# (Removing the previous weird /frankenphp/* rules to let git submodule handle it)
EOF

# 2. Handle FrankenPHP (Inner Repo)
echo ">>> Processing FrankenPHP Repository..."
cd frankenphp

# Fix origin to point to user's fork if it's currently pointing to original
# We assume 'origin' should be the USER's fork for writing.
CURRENT_ORIGIN=$(git remote get-url origin)
USER_FORK_URL="https://github.com/flycoo/frankenphp.git"

if [[ "$CURRENT_ORIGIN" != *"$USER_FORK_URL"* ]]; then
    echo "Updating origin remote to your fork..."
    git remote set-url origin "$USER_FORK_URL"
fi

# Ensure upstream is pointing to official
if ! git remote | grep -q "upstream"; then
    echo "Adding upstream remote..."
    git remote add upstream https://github.com/php/frankenphp.git
fi

# Create and switch to a new branch for the study
BRANCH_NAME="study/logging-trace"
if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
    echo "Branch $BRANCH_NAME already exists, switching..."
    git checkout $BRANCH_NAME
else
    echo "Creating new branch: $BRANCH_NAME"
    git checkout -b $BRANCH_NAME
fi

# Add modifications
git add caddy/module.go frankenphp.c threadworker.go testdata/worker.php

# Commit
if [[ -n $(git status -s) ]]; then
    echo "Committing logging changes in FrankenPHP..."
    git commit -m "study: add logs to trace request lifecycle"
else
    echo "No changes to commit in FrankenPHP."
fi

# Push
echo "Pushing branch $BRANCH_NAME to origin..."
git push -u origin $BRANCH_NAME

# 3. Handle Root Repo (Learning Environment)
echo ">>> Processing Learning Repository..."
cd ..

# Add files
git add .gitignore setup_git.sh setup_git_gh.sh setup_phpsrc.sh setup_watcher.sh commit_changes.sh docs .vscode/*.json

# Add the submodule change (this records the new commit hash from the inner repo)
git add frankenphp php-src watcher

# Commit
if [[ -n $(git status -s) ]]; then
    echo "Committing updates to learning repo..."
    git commit -m "study: update tracking for logging trace branch"
    git push -u origin main
else
    echo "No changes in root repo."
fi

echo "=== All Done! ==="
echo "FrankenPHP (Fork) Branch: $BRANCH_NAME"
echo "Learning Repo Branch: main"
