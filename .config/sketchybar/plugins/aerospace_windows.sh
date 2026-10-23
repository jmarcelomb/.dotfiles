#!/usr/bin/env bash

# Workspace updater using real PNG app icons. Mac mini island style.
# The ws_island bracket provides the dark island background for all
# workspaces. The focused workspace gets a ws_pill bracket that draws
# one single rounded rectangle (corner_radius=5) spanning the letter
# and all app icons, so only the outside corners are rounded.
# Per-item backgrounds are OFF; the bracket provides the pill.

source "$CONFIG_DIR/helpers/theme.sh"

ICONS_DIR="$CONFIG_DIR/icons"
WORKSPACES=(1 2 3 4 5 6 7 8 9 10 A B S T)
MAX_APP_ICONS=3

FOCUSED="$(aerospace list-workspaces --focused)"
RAW="$(aerospace list-windows --all --format '%{workspace}|%{app-name}')"

__icon_png() {
  icon_result=""
  local name="$1"
  name="${name%% (*}"
  local safe_name
  safe_name=$(echo "$name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
  local path="$ICONS_DIR/${safe_name}.png"
  [ -f "$path" ] && icon_result="$path"
}

args=()
for sid in "${WORKSPACES[@]}"; do
  apps=()
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    apps+=("$app")
  done < <(
    printf '%s\n' "$RAW" | awk -F'|' -v ws="$sid" '
      $1 == ws {
        app = $2; gsub(/^ +| +$/, "", app)
        if (app != "" && !seen[app]++) print app
      }'
  )

  has_icons=0

  for ((i = 0; i < MAX_APP_ICONS; i++)); do
    if (( i < ${#apps[@]} )); then
      __icon_png "${apps[$i]}"
      if [ -n "$icon_result" ]; then
        has_icons=1
        # App icon: image only, no per-item background.
        # The ws_pill bracket draws the pill behind it.
        args+=(
          --set "app.$sid.$i"
          drawing=on
          background.image="$icon_result"
          background.image.scale=0.5
          background.drawing=on
          background.color=0x00000000
          background.height=20
          background.corner_radius=0
          background.padding_left=0
          background.padding_right=0
          padding_left=0
          padding_right=0
        )
      else
        args+=(--set "app.$sid.$i" drawing=off)
      fi
    else
      args+=(--set "app.$sid.$i" drawing=off)
    fi
  done

  # Workspace letter: no per-item background. The bracket draws the pill.
  if [ "$has_icons" = 1 ]; then
    if [ "$sid" = "$FOCUSED" ]; then
      args+=(
        --set "space.$sid"
        label.drawing=off
        icon.padding_left=6 icon.padding_right=0
        padding_right=0
        background.drawing=off
        icon.color=$FOCUS_TEXT
      )
    else
      args+=(
        --set "space.$sid"
        label.drawing=off
        icon.padding_left=6 icon.padding_right=2
        background.drawing=off
        icon.color=$TEXT
      )
    fi
  else
    if [ "$sid" = "$FOCUSED" ]; then
      args+=(
        --set "space.$sid"
        label.drawing=off
        icon.padding_left=6 icon.padding_right=6
        background.drawing=off
        icon.color=$FOCUS_TEXT
      )
    else
      args+=(
        --set "space.$sid"
        label.drawing=off
        icon.padding_left=6 icon.padding_right=6
        background.drawing=off
        icon.color=$TEXT
      )
    fi
  fi

  # ws_pill bracket: one rounded rectangle spanning letter + icons.
  # Only the focused workspace shows it. This gives rounded outside
  # corners with no gap between the letter and the icons.
  if [ "$sid" = "$FOCUSED" ]; then
    args+=(
      --set "ws_pill.$sid"
      background.drawing=on
      background.color=$FOCUS_BG
      background.corner_radius=5
      background.height=20
      background.border_width=0
    )
  else
    args+=(
      --set "ws_pill.$sid"
      background.drawing=off
    )
  fi
done

sketchybar "${args[@]}"
