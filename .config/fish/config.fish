if status is-interactive
    alias cat="bat"
    alias nix-rebuild="darwin-rebuild switch --impure --flake ~/.dotfiles/nix and cd ~/.dotfiles/npm and npm install"
    alias nix-update="cd ~/.dotfiles/nix && nix flake update --impure --commit-lock-file && cd ~/.dotfiles/npm and npm update"
    alias ls="eza"
    alias glow="glow -s $HOME/.config/glow/catppuccin.json"

    starship init fish | source
    direnv hook fish | source
    atuin init fish | source
    set -x EDITOR hx
end
