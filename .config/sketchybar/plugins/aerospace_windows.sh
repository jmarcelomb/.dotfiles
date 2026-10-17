#!/usr/bin/env bash

# Single updater for all workspace items. Subscribed to
# aerospace_workspace_change by the hidden aerospace_helper item, so ONE run
# (one `aerospace list-windows --all`, one batched sketchybar call) refreshes
# every workspace instead of one process per item per event.

source "$CONFIG_DIR/helpers/icon_map.sh"
source "$CONFIG_DIR/helpers/theme.sh"

WORKSPACES=(1 2 3 4 5 6 7 8 9 10 A B S T)
FOCUSED="$(aerospace list-workspaces --focused)"
RAW="$(aerospace list-windows --all --format '%{workspace}|%{app-name}')"

args=()
for sid in "${WORKSPACES[@]}"; do
  ICONS=""
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    __icon_map "$app"
    # Apps the font does not know contribute no icon; the workspace letter
    # still identifies the item.
    [ -n "$icon_result" ] && ICONS+="$icon_result "
  done < <(
    printf '%s\n' "$RAW" | awk -F'|' -v ws="$sid" '
      $1 == ws {
        app = $2; gsub(/^ +| +$/, "", app)
        sub(/^Microsoft /, "", app)
        if (app != "" && !seen[app]++) print app
      }'
  )
  ICONS="${ICONS% }"

  # Centering: a bare number/letter gets symmetric padding around the icon;
  # an item with app glyphs keeps a small gap after the letter and breathing
  # room after the glyphs.
  if [ -z "$ICONS" ]; then
    PADS=(icon.padding_left=8 icon.padding_right=8 label.padding_left=0 label.padding_right=0)
  else
    PADS=(icon.padding_left=8 icon.padding_right=3 label.padding_left=1 label.padding_right=6)
  fi

  if [ "$sid" = "$FOCUSED" ]; then
    args+=(--set "space.$sid" label="$ICONS" "${PADS[@]}" \
      background.drawing=on background.color=$FOCUS_BG \
      icon.color=$FOCUS_TEXT label.color=$FOCUS_TEXT)
  else
    args+=(--set "space.$sid" label="$ICONS" "${PADS[@]}" \
      background.drawing=off \
      icon.color=$TEXT label.color=$TEXT)
  fi
done

sketchybar "${args[@]}"
