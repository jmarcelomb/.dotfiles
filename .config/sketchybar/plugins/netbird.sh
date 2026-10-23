#!/usr/bin/env bash

# Netbird VPN status. Shows the orange bird icon with no background.
# When disconnected, dims the icon to indicate the VPN is down.
# Slow poll only; the tailnet state changes rarely.

source "$CONFIG_DIR/helpers/theme.sh"

ICON="$CONFIG_DIR/helpers/netbird.png"

STATUS="$(/usr/local/bin/netbird status --detail 2>/dev/null)"

if echo "$STATUS" | grep -q "Management: Connected" && \
   echo "$STATUS" | grep -q "Signal: Connected"; then
  sketchybar --set netbird \
    icon="" icon.drawing=on icon.width=20 \
    icon.background.image="$ICON" \
    icon.background.image.scale=0.5 \
    icon.background.drawing=on \
    icon.background.color=$BAR_BG \
    icon.background.height=20 \
    icon.background.corner_radius=0 \
    icon.background.padding_left=0 \
    icon.background.padding_right=0 \
    label="" label.color=$TEXT
else
  sketchybar --set netbird \
    icon="" icon.drawing=on icon.width=20 \
    icon.background.image="$ICON" \
    icon.background.image.scale=0.5 \
    icon.background.drawing=on \
    icon.background.color=$BAR_BG \
    icon.background.height=20 \
    icon.background.corner_radius=0 \
    icon.background.padding_left=0 \
    icon.background.padding_right=0 \
    label="nb" label.color=$RED
fi
