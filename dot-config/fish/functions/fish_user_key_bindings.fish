function fish_user_key_bindings
    # Bind Ctrl+G to edit command buffer in Neovim (consistent with Claude Code)
    # Works in vi mode insert and normal modes
    bind -M insert \cg edit_command_buffer
    bind -M default \cg edit_command_buffer
end
