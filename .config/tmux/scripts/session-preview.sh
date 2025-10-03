#!/usr/bin/env bash
# session-preview.sh
# Shows the preview for a session in fzf:
#   - All panes per window
#   - Most recent content first
#   - Color preserved
#   - Compact layout similar to tmux window switch preview

session="$1"
LINES_PER_PANE=8 # number of lines to show per pane

# Check if session exists
if ! tmux has-session -t "$session" 2>/dev/null; then
  echo -e "\033[1;31mSession '$session' not found\033[0m"
  exit 0
fi

# Get session info
session_info=$(tmux display-message -p -t "$session" "#{t:session_created}")
window_count=$(tmux list-windows -t "$session" | wc -l | tr -d ' ')
pane_total=$(tmux list-panes -t "$session" -a | wc -l | tr -d ' ')
is_attached=$(tmux list-clients -t "$session" 2>/dev/null | wc -l | tr -d ' ')
attached_info=$([ "$is_attached" -gt 0 ] && echo " (${is_attached} clients)" || echo " (detached)")

echo -e "\033[1;36m╭─ Session: $session ($window_count windows, $pane_total panes)$attached_info ─╮\033[0m"
echo -e "\033[0;36m│ Created: $session_info\033[0m"
echo -e "\033[1;36m╰─────────────────────────────────────────────────────────────╯\033[0m"
echo

# Iterate over windows
for w in $(tmux list-windows -t "$session" -F '#I'); do
  # Get window info
  window_name=$(tmux list-windows -t "$session:$w" -F '#{window_name}')

  is_active_window=$(tmux list-windows -t "$session:$w" -F '#{?window_active,1,0}')
  pane_count=$(tmux list-panes -t "$session:$w" | wc -l | tr -d ' ')

  active_marker=$([ "$is_active_window" = "1" ] && echo " ●" || echo "")

  echo -e "\033[1;33m╭─ Window $w: $window_name$active_marker ($pane_count panes) ─╮\033[0m"

  # Get all panes in this window
  pane_index=0
  for pane_info in $(tmux list-panes -t "$session:$w" -F '#{pane_id}:#{?pane_active,1,0}:#{pane_current_command}:#{pane_current_path}'); do
    pane_index=$((pane_index + 1))

    IFS=':' read -r pane_id is_active pane_cmd pane_path <<<"$pane_info"
    active_marker=$([ "$is_active" = "1" ] && echo " ●" || echo "")

    # Show current directory basename
    dir_name=$(basename "$pane_path")

    echo -e "\033[1;32m├── Pane $pane_index$active_marker [$pane_cmd] ~/$dir_name\033[0m"

    # Capture the current visible viewport content with limited range
    # Use a safer approach - capture just what we need, not the full pane height
    safe_lines=$((LINES_PER_PANE + 2))
    current_content=$(tmux capture-pane -pt "$pane_id" -S 0 -E $safe_lines -e -J 2>/dev/null)

    if [ -n "$current_content" ]; then
      # Filter empty lines from current content
      filtered_current=$(echo "$current_content" | sed '/^[[:space:]]*$/d')
      current_lines=$(echo "$filtered_current" | wc -l | tr -d ' ')

      if [ "$current_lines" -gt $LINES_PER_PANE ]; then
        # Show top 2 lines of current view + bottom 4 lines (most recent)
        top_current=$(echo "$filtered_current" | head -n 3)
        bottom_current=$(echo "$filtered_current" | tail -n 8)

        if [ -n "$top_current" ]; then
          printf '%s\n' "$top_current" | sed 's/^/│   /'
        fi
        echo -e "\033[0;90m│   ⋮\033[0m"
        if [ -n "$bottom_current" ]; then
          printf '%s\n' "$bottom_current" | sed 's/^/│   /'
        fi
      else
        # Show all visible content if it fits, but limit to LINES_PER_PANE
        echo "$filtered_current" | head -n $LINES_PER_PANE | sed 's/^/│   /'
      fi
    else
      echo -e "\033[0;90m│   (empty pane)\033[0m"
    fi

    # Add separator between panes (except for last pane)
    if [ "$pane_index" -lt "$pane_count" ]; then
      echo -e "\033[0;90m│\033[0m"
    fi
  done

  echo -e "\033[1;33m╰─────────────────────────────────────────────────────────────╯\033[0m"
  echo
done
