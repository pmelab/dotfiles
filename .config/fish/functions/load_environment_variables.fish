function load_environment_variables
    set -l config_file "$HOME/.config/environment.conf"
    
    if not test -f $config_file
        echo "Environment config file not found: $config_file"
        return 1
    end
    
    # Read the config file line by line
    while read -l line
        # Skip empty lines and comments
        if test -z "$line"; or string match -r "^\s*#" "$line"
            continue
        end
        
        # Split line into variable name and value
        set -l parts (string split -m 1 "=" "$line")
        if test (count $parts) -ne 2
            continue
        end
        
        set -l var_name $parts[1]
        set -l var_value $parts[2]
        
        # Handle different value types
        if string match -q "op://*" "$var_value"
            # 1Password secret
            set -gx $var_name (op read "$var_value")
        else if string match -q "cmd://*" "$var_value"
            # Dynamic command
            set -l command (string sub -s 7 "$var_value") # Remove "cmd://" prefix
            set -gx $var_name (eval $command)
        else
            # Static value
            set -gx $var_name $var_value
        end
    end < $config_file
end