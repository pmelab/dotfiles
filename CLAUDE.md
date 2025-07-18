# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a modern dotfiles repository using a hybrid package management approach:
- **Nix Darwin** (nix/) for system-level configuration and programming language tools
- **Homebrew** (Brewfile) for CLI utilities and GUI applications  
- **GNU Stow** for symlink management of configuration files
- **npm** (npm/) for language servers and development tools

The configuration follows XDG Base Directory specification with most configs in `.config/`.

## Common Commands

### System Management
- `~/bin/dotfiles-build` - Rebuild entire system configuration using darwin-rebuild
- `~/bin/dotfiles-update` - Update Nix flake dependencies and commit lock file
- `brew bundle --file ~/.dotfiles/Brewfile` - Install/update Homebrew packages
- `stow .` - Create symlinks for dotfiles (run from ~/.dotfiles/)

### Development Tools
- Primary editor: **Helix** (`.config/helix/`)
- Secondary editor: **Neovim** (`.config/nvim/`)
- Terminal: **Ghostty** (`.config/ghostty/`)
- Shell: **Fish** with **Starship** prompt
- Git UI: **lazygit**
- File manager: **yazi**

### Language Server Management
- Language servers are managed via npm in `npm/package.json`
- Run `npm install` in the npm/ directory to install/update language servers
- Includes TypeScript, GraphQL, Tailwind CSS, and other development tools

## Key Configuration Areas

- `nix/flake.nix` - Main system configuration defining Nix packages and Homebrew integration
- `.config/fish/config.fish` - Shell configuration with modern CLI tool aliases
- `.config/helix/` - Primary editor configuration with LSP setup
- `.gitconfig` - Git configuration with 1Password SSH signing
- `Brewfile` - Homebrew package definitions

## Development Environment Features

- Modern CLI tools: bat, eza, fd, ripgrep, fzf, zoxide
- Integrated development: Python (with debugpy), PHP (with phpactor), JavaScript/TypeScript
- Container development: Docker via Lima, DDEV for Drupal development
- History and navigation: Atuin for shell history, zoxide for smart directory jumping

## Package Management Workflow

### Nix Packages (Programming Languages & Core Tools)
- Edit `nix/flake.nix` to add/remove system packages
- Run `~/bin/dotfiles-build` to apply changes
- Run `~/bin/dotfiles-update` to update Nix flake lock file

### Homebrew Packages (CLI Tools & Applications)
- Edit `Brewfile` to add/remove packages
- Run `brew bundle --file ~/.dotfiles/Brewfile` to install/update

### Language Servers & Development Tools
- Edit `npm/package.json` to add/remove language servers
- Run `npm install` in the npm/ directory to install/update
- Language servers are accessible via PATH from Fish shell configuration

### Configuration Deployment
- Use `stow .` from ~/.dotfiles/ to create symlinks for configuration files
- Files listed in `.stow-local-ignore` (npm, nix, bin, .git) are excluded from symlinking

## Important Aliases & Commands

From Fish shell configuration:
- `cat` → `bat` (syntax highlighted file viewing)
- `ls` → `eza` (modern ls replacement)
- `cd` → `zoxide` (smart directory jumping)
- `pu` → `php vendor/bin/phpunit --filter` (PHP unit testing)
- `pud` → `php -d xdebug.mode=debug vendor/bin/phpunit --filter` (PHP unit testing with debug)

## Editor Configuration

- **Helix**: Primary editor with comprehensive LSP setup in `.config/helix/languages.toml`
  - Python: pyright + ruff
  - PHP: phpactor
  - JavaScript/TypeScript: eslint + typescript-language-server
  - JSON: vscode-json-language-server
- **Neovim**: Secondary editor with Laravel/Drupal specific tooling

## Container & Development Environment

- Docker runs via Lima (not Docker Desktop)
- DDEV for Drupal development workflows
- Environment variables managed through 1Password CLI integration
- direnv for automatic environment loading