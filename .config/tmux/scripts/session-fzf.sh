#!/usr/bin/env bash
# Popup session switcher + creator with live preview of windows/panes

# Capture the selected session (via fzf)
result=$(tmux list-sessions -F '#S' |
  fzf --cycle --reverse --print-query \
    --preview "$HOME/.config/tmux/scripts/session-preview.sh {}" \
    --preview-window=right:90% \
    --bind "ctrl-k:execute(tmux kill-session -t {})+reload(tmux list-sessions -F '#S')" \
    --bind "ctrl-u:preview-up" \
    --bind "ctrl-d:preview-down" \
    --bind "ctrl-b:preview-page-up" \
    --bind "ctrl-f:preview-page-down" \
    --bind "shift-up:preview-up" \
    --bind "shift-down:preview-down")

# Extract query and selected session
query=$(echo "$result" | sed -n 1p)
session=$(echo "$result" | sed -n 2p)

# Switch or create
if [ -n "$session" ]; then
  tmux switch-client -t "$session"
elif [ -n "$query" ]; then
  tmux new-session -d -s "$query" && tmux switch-client -t "$query"
fi
