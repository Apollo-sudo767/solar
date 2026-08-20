#!/usr/bin/env bash
# sync-wiki.sh
# Synchronizes the local wiki/ folder to the remote GitHub Wiki repository.
set -e

WIKI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "☀️ Syncing Solar Wiki to GitHub..."

# Remote repository URL for GitHub Wiki
WIKI_REMOTE="git@github.com:Apollo-sudo767/solar.wiki.git"

echo "📥 Cloning wiki repository..."
if ! git clone "$WIKI_REMOTE" "$TEMP_DIR/wiki" 2>/dev/null; then
    echo "⚠️  GitHub Wiki not initialized yet."
    echo "To initialize, go to: https://github.com/Apollo-sudo767/solar/wiki"
    echo "Click 'Create the first page' and save it once, then re-run this script."
    exit 1
fi

echo "📋 Copying wiki pages..."
find "$WIKI_DIR" -maxdepth 1 -name "*.md" -exec cp {} "$TEMP_DIR/wiki/" \;

cd "$TEMP_DIR/wiki"
git add .
if git diff-index --quiet HEAD --; then
    echo "✅ GitHub Wiki is already up to date."
else
    git commit -m "docs: sync wiki documentation from main repository"
    git push origin master || git push origin main
    echo "🚀 Wiki successfully pushed to GitHub!"
fi
