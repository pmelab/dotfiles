if status is-interactive
    alias cat="bat"
    alias ls="eza"
    alias glow="glow -s $HOME/.config/glow/catppuccin.json"

    starship init fish | source
    direnv hook fish | source
    atuin init fish | source
    set -x EDITOR hx
    fish_add_path --path ~/.dotfiles/npm/node_modules/.bin/
    fish_add_path --path ~/.dotfiles/bin/
    fish_add_path --path /opt/homebrew/bin/
end
