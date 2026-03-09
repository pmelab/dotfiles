# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). macOS-focused, fish shell, Neovim, secrets via age/1Password.

## Setup

```bash
# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# clone and stow
git clone git@github.com:<user>/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
brew bundle
stow .

# set fish as default shell
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# install dev tools
mise install

# build bat theme cache (Catppuccin)
bat cache --build

# restore cmux preferences
defaults import com.cmuxterm.app ~/.dotfiles/macos/com.cmuxterm.app.plist
# (re-export after changing cmux settings: defaults export com.cmuxterm.app ~/.dotfiles/macos/com.cmuxterm.app.plist)

# restore secrets (age key for fnox)
op document get "fnox age key" --vault Development --out-file ~/.config/fnox/age.txt
```

Stow uses the `--dotfiles` flag (configured in `.stowrc`), so `dot-config/` becomes `.config/`, `dot-gitconfig` becomes `.gitconfig`, etc.

## Structure

```
dot-agents/          AI agent skills lock file (~/.agents/)
dot-config/
  atuin/             Shell history with sync
  bat/               Cat replacement (Catppuccin theme)
  ghostty/           Terminal emulator (Catppuccin Mocha, Geist Mono)
  btop/              System monitor
  fish/              Shell config, aliases, env vars
  fnox/              Secrets management (age encryption)
  gh/                GitHub CLI config
  git/               Global gitignore
  glow/              Markdown viewer (Catppuccin theme)
  gtd/               GTD tool config
  htop/              Process viewer
  lazygit/           Git TUI
  mise/              Tool version manager
  nvim/              Neovim (lazy.nvim, LSP)
  starship.toml      Prompt
  worktrunk/         Git worktree manager
  yazi/              File manager
dot-gitconfig        Git config (delta, SSH signing via 1Password)
Brewfile             All homebrew dependencies
macos/               macOS app preferences (restore with `defaults import`)
bin/                 Custom scripts
```

## Key tools

| Tool              | Purpose                                           |
| ----------------- | ------------------------------------------------- |
| **fish**          | Shell                                             |
| **starship**      | Prompt                                            |
| **atuin**         | Shell history with sync                           |
| **zoxide**        | Smart `cd` (frecency)                             |
| **mise**          | Tool/env manager (see [Mise](#mise) below)        |
| **fnox**          | Secrets management (age + 1Password providers)    |
| **Neovim**        | Editor (lazy.nvim, LSP)                           |
| **lazygit**       | Git TUI with delta diffs                          |
| **lazydocker**    | Docker TUI                                        |
| **bat**           | `cat` replacement                                 |
| **eza**           | `ls` replacement                                  |
| **ripgrep**       | `grep` replacement                                |
| **yazi**          | Terminal file manager                             |
| **glow**          | Markdown viewer                                   |
| **fzf**           | Fuzzy finder                                      |
| **delta**         | Git diff viewer (Catppuccin Mocha)                |
| **gh**            | GitHub CLI (with gh-dash extension)               |
| **cmux**          | Terminal multiplexer                              |
| **pi**            | AI coding agent                                   |
| **1Password CLI** | SSH signing, secrets bootstrap                    |

## Secrets

Secrets are managed with **fnox** using two providers:

- **age** — local encryption/decryption, no network needed. The age private key lives at `~/.config/fnox/age.txt` (stored in 1Password, not tracked in git).
- **1Password** — cloud-based fallback via service account.

Bootstrap flow: fish config loads `OP_SERVICE_ACCOUNT_TOKEN` from fnox (age-decrypted), which enables 1Password CLI for everything else.

Managed secrets include GitHub PAT, Amazee.ai tokens, Gemini/Mistral API keys, Brave Search API key.

## Git

- Commits are **SSH-signed via 1Password** (`op-ssh-sign`)
- Default pull strategy: **rebase**
- Diff pager: **delta** with Catppuccin Mocha theme
- Editor: **nvim**

## Mise

Global config at `dot-config/mise/config.toml`. Manages dev tools (like Brewfile but for language runtimes/CLI tools) and environment variables.

**Global tools:**

| Tool                    | Version    |
| ----------------------- | ---------- |
| node                    | 25.x       |
| pnpm                    | 10.x       |
| prettier                | 3.x        |
| pitchfork               | latest     |
| yaml-language-server    | latest     |
| pi                      | latest     |

**Environment variables:** sets `EDITOR`, `OP_ACCOUNT`, `DOCKER_HOST` (Lima), Amazee.ai config, and loads secrets via the `mise-env-fnox` plugin.

**Secrets integration:** the `mise-env-fnox` plugin searches upward for `fnox.toml` files and injects decrypted secrets as env vars. Per-project secrets are defined in each repo's `fnox.toml`.

`trusted_config_paths` includes `~/Code` so project-level `.mise.toml` files are auto-trusted.

## Neovim

Plugin manager: **lazy.nvim** (stable branch). Config is a single `init.lua`.

Highlights:

- LSP via mason + nvim-lspconfig
- conform.nvim for formatting (prettier, stylua; pint auto-detected per project)
- flash.nvim, oil.nvim for navigation
- nvim-cmp for completion
- nvim-highlight-colors for inline color previews
- Catppuccin Mocha theme

## Shell aliases

```fish
cat    → bat
ls     → eza
cd     → zoxide
glow   → glow -s ~/.config/glow/catppuccin.json
pf     → pitchfork
mi     → mise
tt     → nvim TODO.md
gstart → git commit --allow-empty -m '!start'
gstop  → git commit --allow-empty -m '!stop'
```

`gh-dash` is auto-installed/upgraded on shell start.

`Ctrl+G` opens the command buffer in Neovim.

## AI Agent Skills

Agent skills for [pi](https://shittycodingagent.ai) and Claude Code are tracked via the [`skills`](https://www.npmjs.com/package/skills) CLI. The global lock file (`~/.agents/.skill-lock.json`) is stowed from `dot-agents/dot-skill-lock.json`, so installs and updates are automatically persisted to this repo.

**Restore all skills on a new machine:**

```bash
npx skills update
```

**Add a new skill:**

```bash
npx skills add <owner/repo@skill> -g -y
```

The lock file updates automatically. Commit `dot-agents/dot-skill-lock.json` to track the change.

## Scripts

| Script                  | Purpose                                                          |
| ----------------------- | ---------------------------------------------------------------- |
| `bin/fnox-sync-1pass`   | Sync all 1Password vault items into fnox as age-encrypted values |
| `bin/amazeeai-balance`  | Query Amazee.ai API key spend/budget                             |
| `bin/playwright-report` | Download and view Playwright reports from GitHub Actions         |
