#!/bin/bash

# Get the current selection from tmux
selection=$(tmux show-buffer 2>/dev/null || echo "")

if [ -z "$selection" ]; then
  # If no selection, just open interactive ask in a popup with new session
  session_name="ai-ask-$(date +%s)"

  # Create fish command to load function and run ask
  fish_cmd="functions -e ask; "
  fish_cmd+="source ~/.config/fish/functions/ask.fish; "
  fish_cmd+="ask -i; "
  fish_cmd+="tmux detach-client"

  tmux display-popup \
    -w 90% \
    -h 80% \
    -E "tmux new-session -s '$session_name' 'fish -c \"$fish_cmd\"'"
else
  # Create a temporary file to avoid shell escaping issues
  temp_file=$(mktemp)
  echo "$selection" >"$temp_file"

  # Create a temporary script to run in the tmux session
  script_file=$(mktemp)
  cat >"$script_file" <<'EOF'
#!/usr/bin/env fish

set temp_file $argv[1]

# Source the fish function
functions -e ask
source ~/.config/fish/functions/ask.fish

cat "$temp_file" | ask -i -p
rm "$temp_file"
tmux detach-client
EOF

  chmod +x "$script_file"

  # Create a new tmux session in popup
  session_name="ai-ask-$(date +%s)"

  tmux display-popup \
    -w 70% \
    -h 80% \
    -E "tmux new-session -s '$session_name' '$script_file $temp_file; rm $script_file'"
fi
