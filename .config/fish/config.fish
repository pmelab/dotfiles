if status is-interactive
    alias cat="bat"
    alias ls="eza"
    alias glow="glow -s $HOME/.config/glow/catppuccin.json"
    alias pud="php -d xdebug.mode=debug vendor/bin/phpunit --filter"
    alias pu="php vendor/bin/phpunit --filter"
    fish_add_path --path /opt/homebrew/bin/
    fish_add_path --path ~/.dotfiles/npm/node_modules/.bin
    fish_add_path --path ~/.dotfiles/bin
    fish_add_path --path ~/.local/bin
    starship init fish | source
    direnv hook fish | source
    atuin init fish | source
    zoxide init --cmd cd fish | source

    # Second Brain aliases and functions
    alias brain="cd '$HOME/Documents/Second Brain'"
    alias brain-serve="$HOME/.dotfiles/bin/second-brain-serve"
    
    function brain-new
        cd "$HOME/Documents/Second Brain" && command zk new $argv
    end
    
    function brain-search
        cd "$HOME/Documents/Second Brain" && command zk edit --interactive $argv
    end
    
    function brain-daily
        cd "$HOME/Documents/Second Brain" && command zk daily
    end

    # Environment variable cache management functions
    function update_env_cache
        set -l cache_file ~/.cache/wezterm-env
        mkdir -p ~/.cache
        
        echo "Updating environment cache from configuration..."
        
        # Clear the cache file
        echo "# Environment variables cached from ~/.config/environment.conf" > $cache_file
        echo "# Generated at $(date)" >> $cache_file
        
        # Load variables using existing function and capture them
        set -l config_file "$HOME/.config/environment.conf"
        
        if test -f $config_file
            # Read the config file and process each line
            for line in (cat $config_file | string match -r -v '^\s*#|^\s*$')
                set -l parts (string split -m 1 "=" "$line")
                if test (count $parts) -ne 2
                    continue
                end
                
                set -l var_name $parts[1]
                set -l var_value $parts[2]
                
                # Load the actual value using the same logic as load_environment_variables
                if string match -q "op://*" "$var_value"
                    # 1Password secret
                    set -l actual_value (op read "$var_value" 2>/dev/null)
                    if test $status -eq 0
                        echo "set -gx $var_name '$actual_value'" >> $cache_file
                    end
                else if string match -q "cmd://*" "$var_value"
                    # Dynamic command
                    set -l command (string sub -s 7 "$var_value")
                    set -l actual_value (eval $command 2>/dev/null)
                    if test $status -eq 0
                        echo "set -gx $var_name '$actual_value'" >> $cache_file
                    end
                else
                    # Static value
                    echo "set -gx $var_name '$var_value'" >> $cache_file
                end
            end
        else
            # Fallback to test variable if no config exists
            echo "set -gx WEZTERM_TEST_VAR loaded_from_cache" >> $cache_file
        end
        
        # Set secure permissions
        chmod 600 $cache_file
        echo "Environment cache updated at $cache_file"
        load_env_cache
    end

    function load_env_cache
        set -l cache_file ~/.cache/wezterm-env
        if test -f $cache_file
            source $cache_file
            echo "Environment variables loaded from cache"
        else
            echo "No environment cache found. Creating initial cache..."
            update_env_cache
        end
    end

    function reload_env_cache
        load_env_cache
    end

    # Prevent Sharp compilation issues with global libvips
    set -gx SHARP_IGNORE_GLOBAL_LIBVIPS 1

    # Load environment variables from cache (auto-creates if missing)
    load_env_cache

end
