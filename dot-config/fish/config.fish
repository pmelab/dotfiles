# Add essential paths first (needed for fnox command)
fish_add_path --path /opt/homebrew/bin/
fish_add_path --path ~/.dotfiles/bin
fish_add_path --path ~/.local/bin
fish_add_path --path ~/Code/gtd/dist

# Bootstrap 1Password service account token for fnox
if command -q fnox
    set -gx OP_SERVICE_ACCOUNT_TOKEN (fnox get OP_SERVICE_ACCOUNT_TOKEN --config ~/.config/fnox/config.toml 2>/dev/null)
end

if status is-interactive
    # Auto-install/upgrade gh-dash extension
    if command -q gh
        if not gh extension list | string match -q '*dlvhdr/gh-dash*'
            gh extension install dlvhdr/gh-dash
        else
            gh extension upgrade gh-dash 2>/dev/null &
        end
    end

    alias cat="bat"
    alias ls="eza"
    alias glow="glow -s $HOME/.config/glow/catppuccin.json"
    alias pf="pitchfork"
    alias mi="mise"
    alias gstart="git commit --allow-empty -m '!start'"
    alias gstop="git commit --allow-empty -m '!stop'"
    alias tt="nvim TODO.md"
    fish_add_path --path ~/.dotfiles/npm/node_modules/.bin
    
    fnox activate fish | source
    mise activate fish | source
    starship init fish | source
    atuin init fish | source
    zoxide init --cmd cd fish | source
    pitchfork activate fish | source
else
    mise activate fish --shims | source
end
