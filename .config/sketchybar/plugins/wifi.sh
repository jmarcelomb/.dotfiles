#!/usr/bin/env bash

# Wifi / network state. Subscribes to wifi_change; the label shows the SSID on
# wifi and the interface name on wired, red and offline when no route.

source "$CONFIG_DIR/helpers/theme.sh"

GLYPH_WIFI='󰖩'   # md-wifi

IFACE="$(route -n get default 2>/dev/null | awk '/interface:/ {print $2}')"

if [ -z "$IFACE" ]; then
  sketchybar --set wifi icon="$GLYPH_WIFI" icon.color=$RED label="offline" label.color=$RED
  exit 0
fi

SSID="$(ipconfig getsummary "$IFACE" 2>/dev/null | awk -F ' SSID: ' '/ SSID: / {print $2; exit}')"

if [ -n "$SSID" ]; then
  sketchybar --set wifi icon="$GLYPH_WIFI" icon.color=$CHARGE label="$SSID" label.color=$DIM
else
  # wired or hidden SSID
  sketchybar --set wifi icon="$GLYPH_WIFI" icon.color=$CHARGE label="" label.color=$DIM
fi
