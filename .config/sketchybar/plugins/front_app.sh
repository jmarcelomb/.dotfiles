#!/usr/bin/env bash

# Front app indicator: focused application icon + name.
# Uses real PNG icons from ~/.config/sketchybar/icons/ extracted
# from macOS app bundles via NSWorkspace. Falls back to text-only
# when no icon PNG exists for the front app.
# macOS UI agents take "frontmost" during alerts; those are ignored.

source "$CONFIG_DIR/helpers/theme.sh"

ICONS_DIR="$CONFIG_DIR/icons"

case "$INFO" in
  "" | UserNotificationCenter | NotificationCenter | Dock | SystemUIServer | WallpaperAgent | ControlCenter | Spotlight)
    sketchybar --set "$NAME" drawing=off
    exit 0
    ;;
esac

# Map app name to PNG path
safe_name=$(echo "$INFO" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
icon_path="$ICONS_DIR/${safe_name}.png"

if [ -f "$icon_path" ]; then
  sketchybar --set "$NAME" drawing=on \
    icon.drawing=on \
    icon.width=20 \
    icon.background.image="$icon_path" \
    icon.background.image.scale=0.5 \
    icon.background.drawing=on \
    icon.background.color=$BAR_BG \
    icon.background.height=20 \
    icon.background.corner_radius=3 \
    icon.background.padding_left=2 \
    icon.background.padding_right=2 \
    label="$INFO" label.color=$TEXT
else
  sketchybar --set "$NAME" drawing=on \
    icon.drawing=off \
    label="$INFO" label.color=$TEXT
fi
