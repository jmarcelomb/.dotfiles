#!/usr/bin/env bash
# Opens the current tmux buffer (if any) in $EDITOR/$VISUAL for editing,
# then launches opencode with the final text pre-filled and auto-submitted.
#
# opencode's CLI --prompt flag auto-submits immediately, so instead of
# passing the raw selection straight through, we let the user review/edit
# it in the editor first. Closing the editor is the "confirm and send"
# action: whatever is left in the file becomes the opencode prompt (empty
# if the user cleared it, which just starts opencode with a blank prompt).
#
# The temp file always lives in the same fixed directory so that, if the
# editor is Helix, its workspace-trust prompt only needs to be answered
# once ("Always") - every invocation after that is silent.

set -uo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/opencode-ask-selection"
mkdir -p "$cache_dir"

selection_file="$(mktemp --suffix=.md -p "$cache_dir" selection.XXXXXX)"
tmux show-buffer >"$selection_file" 2>/dev/null

cleanup() {
	rm -f "$selection_file"
}
trap cleanup EXIT

(cd "$cache_dir" && "${VISUAL:-${EDITOR:-vi}}" "$selection_file")

prompt="$(cat "$selection_file")"

cd "$(tmux display-message -p '#{pane_current_path}')" 2>/dev/null || true

if [ -n "$prompt" ]; then
	opencode --prompt "$prompt"
else
	opencode
fi
