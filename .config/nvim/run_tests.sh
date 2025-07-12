#!/bin/bash

# Script to run Neovim configuration tests locally

set -e

echo "🧪 Running Neovim Configuration Tests"
echo "======================================"

# Check if we're in the right directory
if [ ! -f "init.lua" ]; then
    echo "❌ Please run this script from the .config/nvim directory"
    exit 1
fi

# Check if nvim is available
if ! command -v nvim &> /dev/null; then
    echo "❌ Neovim is not installed or not in PATH"
    exit 1
fi

echo "📋 Running infrastructure tests..."
nvim --headless -u tests/minimal.vim -c "lua require('plenary.busted')" -c "PlenaryBustedFile tests/spec/infrastructure_spec.lua"

echo ""
echo "🔍 Running project detection tests..."
nvim --headless -u tests/minimal.vim -c "lua require('plenary.busted')" -c "PlenaryBustedFile tests/spec/project_detection_spec.lua"

echo ""
echo "🏃 Running all tests..."
nvim --headless -u tests/minimal.vim -c "lua require('plenary.busted')" -c "PlenaryBustedDirectory tests/spec/"

echo ""
echo "⚡ Testing basic config loading..."
timeout 10s nvim --headless -u init.lua -c "sleep 1" -c "qa!" && echo "✅ Config loads successfully" || echo "❌ Config loading failed"

echo ""
echo "⏱️  Measuring startup time..."
start_time=$(gdate +%s%N 2>/dev/null || date +%s%N)
timeout 5s nvim --headless -u init.lua -c "qa!" 2>/dev/null || true
end_time=$(gdate +%s%N 2>/dev/null || date +%s%N)
startup_time=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
echo "Startup time: ${startup_time}ms"

if [ $startup_time -gt 2000 ]; then
    echo "⚠️  Startup time is slow (>${startup_time}ms)"
else
    echo "✅ Startup time is good"
fi

echo ""
echo "🎉 All tests completed!"