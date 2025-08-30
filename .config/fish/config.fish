if status is-interactive
    alias cat="bat"
    alias ls="eza"
    alias glow="glow -s $HOME/.config/glow/catppuccin.json"
    alias pud="php -d xdebug.mode=debug vendor/bin/phpunit --filter"
    alias pu="php vendor/bin/phpunit --filter"
    fish_add_path --path /opt/homebrew/bin/
    fish_add_path --path ~/.dotfiles/npm/node_modules/.bin
    starship init fish | source
    direnv hook fish | source
    atuin init fish | source
    zoxide init --cmd cd fish | source
    function za
        zellij attach $(zellij ls -s | fzf)
    end

    function zk
        zellij kill-session $(zellij ls -s | fzf)
    end

    # Prevent Sharp compilation issues with global libvips
    set -gx SHARP_IGNORE_GLOBAL_LIBVIPS 1

    # Regenerate Zellij config to ensure it's in sync with environment.conf
    ~/.dotfiles/bin/generate-zellij-config >/dev/null 2>&1

    # Load environment variables from config file
    # Only initialize environment variables if not in a Zellij session
    if not set -q ZELLIJ
        load_environment_variables
    end
end
