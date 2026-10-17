#!/usr/bin/env bash
# Toggle a floating scratch pane using tmux 3.7's native new-pane command.
#
# Native floating panes (tmux 3.7+) always render on top of the tiled
# layout and can't be hidden/detached like a popup, so "toggle" here means:
#   - no scratch pane exists  -> create one (floating, marked via a pane
#                                 user option since fish/shells overwrite
#                                 pane titles via OSC sequences)
#   - scratch pane exists     -> jump to it (switch window + select it)
#   - scratch pane is active  -> kill it (closes the pane and its process)
#
# Caveat: unlike tmux-floax's popup (backed by a persistent detached
# session), killing the scratch pane here ends its shell. There's no
# state persistence across toggles until tmux 3.8 adds join-pane -f /
# resize-pane support for floating panes.

set -euo pipefail

scratch_pane="$(tmux list-panes -a -f "#{&&:#{pane_floating_flag},#{@scratch_pane}}" -F '#{pane_id}' | head -n1)"
active_pane="$(tmux display-message -p '#{pane_id}')"

if [ -z "$scratch_pane" ]; then
    tmux new-pane -c "#{pane_current_path}"
    tmux set-option -p @scratch_pane 1
    exit 0
fi

if [ "$scratch_pane" = "$active_pane" ]; then
    tmux kill-pane -t "$scratch_pane"
    exit 0
fi

scratch_window="$(tmux list-panes -a -f "#{==:#{pane_id},${scratch_pane}}" -F '#{window_id}')"
tmux select-window -t "$scratch_window"
tmux select-pane -t "$scratch_pane"
