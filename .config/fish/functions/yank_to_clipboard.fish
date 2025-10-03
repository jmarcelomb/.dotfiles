function yank_to_clipboard -d "Insert latest killring entry into system clipboard"
    printf "%s" "$fish_killring[1]" | fish_clipboard_copy
end
