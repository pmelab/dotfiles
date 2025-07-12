# Neovim Configuration Testing

This directory contains automated tests for the Neovim configuration to ensure reliability and prevent regressions.

## Overview

The testing setup includes:
- **Project Detection Tests**: Validate Laravel, Drupal, Storybook, and Python project detection
- **LSP Configuration Tests**: Ensure correct LSP setup based on project types
- **Keymap Validation Tests**: Verify all custom keymaps are properly registered
- **Plugin Loading Tests**: Check that plugins load without errors
- **Infrastructure Tests**: Basic validation of the test environment
- **Performance Tests**: Startup time monitoring

## Quick Start

### Running Tests Locally

```bash
# Run all tests
./run_tests.sh

# Run specific test files
nvim --headless -u tests/minimal.vim -c "lua require('plenary.busted')" -c "PlenaryBustedFile tests/spec/project_detection_spec.lua"
```

### Installing Pre-commit Hooks

```bash
# Install git pre-commit hooks (run from dotfiles root)
./.config/nvim/install_hooks.sh
```

## Test Structure

```
tests/
├── minimal.vim              # Minimal Neovim config for testing
├── test_helpers.lua          # Helper functions and mocks
└── spec/
    ├── infrastructure_spec.lua     # Basic test environment validation
    ├── project_detection_spec.lua  # Project type detection tests
    ├── lsp_config_spec.lua         # LSP configuration tests
    ├── keymap_validation_spec.lua  # Keymap verification tests
    └── plugin_loading_spec.lua     # Plugin loading tests
```

## Test Categories

### Project Detection Tests
- Laravel project detection (artisan + composer.json)
- Drupal project detection (drupal/core in composer.json)
- Storybook project detection (.storybook directory or @storybook packages)
- Python project detection (pyproject.toml, requirements.txt, etc.)
- Silverback Drupal root detection
- Pint formatter detection

### LSP Configuration Tests
- Conditional LSP setup based on project types
- Formatter selection (Pint vs phpcbf vs others)
- Error handling for missing dependencies
- Multiple project types in same directory

### Keymap Validation Tests
- Basic navigation keymaps (j/k for soft wraps, Esc to clear highlights)
- Leader key configuration
- Plugin-specific keymaps
- Mode-specific behaviors
- Conflict detection

### Plugin Loading Tests
- Essential plugin loading (plenary, lazy.nvim, mason)
- LSP plugin integration
- UI plugin availability
- Lazy loading validation
- Error handling for missing plugins

## Continuous Integration

GitHub Actions automatically run tests on:
- Linux and macOS
- Neovim versions: v0.9.4, v0.10.1, nightly
- Pull requests and pushes to main branch

### CI Features
- Cross-platform testing
- Multiple Neovim version matrix
- Startup performance monitoring
- Lua code formatting checks (StyLua)
- Language server installation testing

## Writing Tests

Tests use the [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) testing framework with busted-style syntax:

```lua
describe('Feature Name', function()
  it('should do something', function()
    local result = some_function()
    assert.is_true(result)
  end)
end)
```

### Test Helpers

The `test_helpers.lua` file provides utilities for:
- Mocking file system operations
- Project detection functions
- LSP configuration utilities

Example:
```lua
local helpers = require('tests.test_helpers')

-- Mock file system
local cleanup = helpers.mock_files({
  ['/project/composer.json'] = { readable = true },
  ['/project/artisan'] = { readable = true },
})

-- Test project detection
local is_laravel = helpers.is_laravel_project('/project/src')
assert.is_true(is_laravel)

-- Clean up
cleanup()
```

## Performance Monitoring

The test suite includes startup time monitoring:
- Measures average startup time over 5 runs
- Fails if startup exceeds 2 seconds
- Runs in CI to catch performance regressions

Current performance: ~109ms startup time

## Local Development

### Pre-commit Hooks

Install pre-commit hooks to automatically run tests before commits:

```bash
./.config/nvim/install_hooks.sh
```

The hook will:
- Run the full test suite
- Check for Lua syntax errors
- Warn about TODO/FIXME comments
- Prevent commits if tests fail

Skip the hook temporarily:
```bash
git commit --no-verify
```

### Test Configuration

The minimal test configuration (`tests/minimal.vim`) loads only essential plugins:
- plenary.nvim for testing
- nvim-lspconfig for utility functions
- lazy.nvim for plugin management

This ensures tests run quickly and focus on configuration logic rather than plugin behavior.

## Troubleshooting

### Common Issues

1. **Tests timeout**: Increase timeout in test commands or check for infinite loops
2. **Plugin not found**: Ensure plugin is included in minimal.vim if needed for tests
3. **LSP errors**: Mock lspconfig functions in test helpers
4. **Keymap conflicts**: Use unique test keymaps and clean up after tests

### Debug Mode

Run tests with more verbose output:
```bash
nvim --headless -u tests/minimal.vim -c "lua vim.g.test_debug = true" -c "lua require('plenary.busted')" -c "PlenaryBustedDirectory tests/spec/"
```

## Contributing

When adding new configuration features:

1. Write tests first (TDD approach)
2. Ensure tests cover edge cases and error conditions
3. Update this documentation if adding new test categories
4. Verify CI passes on all platforms and Neovim versions

Test coverage goals:
- All project detection logic
- All conditional LSP configurations
- Critical keymaps and plugin integrations
- Error handling and edge cases