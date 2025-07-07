if status is-interactive
    alias cat="bat"
    alias ls="eza"
    alias glow="glow -s $HOME/.config/glow/catppuccin.json"
    alias pud="php -d xdebug.mode=debug vendor/bin/phpunit --filter"
    alias pu="php vendor/bin/phpunit --filter"
    fish_add_path --path /opt/homebrew/bin/
    starship init fish | source
    direnv hook fish | source
    atuin init fish | source
    zoxide init --cmd cd fish | source

    # Load environment variables from config file
    # Only initialize environment variables if not in a Zellij session
    if not set -q ZELLIJ
        load_environment_variables
    end

    # Regenerate Zellij config to ensure it's in sync with environment.conf
    ~/.dotfiles/bin/generate-zellij-config > /dev/null 2>&1

    set -x ZELLIJ_AUTO_ATTACH true
    eval (zellij setup --generate-auto-start fish | string collect)
end
alias claude="/Users/pmelab/.claude/local/claude"
