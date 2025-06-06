if status is-interactive
    alias cat="bat"
    alias ls="eza"
    alias glow="glow -s $HOME/.config/glow/catppuccin.json"
    alias pud="php -d xdebug.mode=debug vendor/bin/phpunit --filter"
    alias pu="php vendor/bin/phpunit --filter"
    fish_add_path --path ~/.dotfiles/npm/node_modules/.bin/
    fish_add_path --path ~/.dotfiles/bin/
    fish_add_path --path /opt/homebrew/bin/
    starship init fish | source
    direnv hook fish | source
    atuin init fish | source
    zoxide init --cmd cd fish | source
    set -x EDITOR hx
    set -x DOCKER_HOST $(limactl list default --format 'unix://{{.Dir}}/sock/docker.sock')
    set -x AMAZEEAI_API_KEY $(op read "op://Personal/amazee.ai LLM/credential")
    set -x AMAZEEAI_BASE_URL "https://llm.de103.amazee.ai"
end
alias claude="/Users/pmelab/.claude/local/claude"
