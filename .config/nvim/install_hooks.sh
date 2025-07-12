#!/bin/bash

# Script to install git pre-commit hooks for Neovim configuration testing

set -e

echo "🔧 Installing git pre-commit hooks for Neovim configuration..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ This directory is not a git repository"
    echo "   Please run this script from the root of your dotfiles repository"
    exit 1
fi

# Check if we have the hook file
HOOK_SOURCE="$PWD/.config/nvim/hooks/pre-commit"
if [ ! -f "$HOOK_SOURCE" ]; then
    echo "❌ Pre-commit hook source not found at: $HOOK_SOURCE"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Install the hook
HOOK_DEST=".git/hooks/pre-commit"

if [ -f "$HOOK_DEST" ]; then
    echo "⚠️  Existing pre-commit hook found"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Installation cancelled"
        exit 1
    fi
    
    # Backup existing hook
    cp "$HOOK_DEST" "$HOOK_DEST.backup.$(date +%s)"
    echo "📦 Backed up existing hook to $HOOK_DEST.backup.$(date +%s)"
fi

# Copy and make executable
cp "$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_DEST"

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "The hook will now:"
echo "  • Run Neovim configuration tests before each commit"
echo "  • Check for Lua syntax errors"
echo "  • Warn about TODO/FIXME comments"
echo "  • Prevent commits if tests fail"
echo ""
echo "To temporarily skip the hook for a commit, use:"
echo "  git commit --no-verify"
echo ""
echo "To uninstall the hook, simply delete:"
echo "  .git/hooks/pre-commit"