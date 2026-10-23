#!/bin/sh

source "$CONFIG_DIR/helpers/theme.sh"

PERCENTAGE="$(pmset -g batt | grep -Eo '[0-9]+%' | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

# Auto-hide on desktops: no percentage means no battery.
if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

case "${PERCENTAGE}" in
9[0-9] | 100)
  ICON="􀛨"
  ;;
[6-8][0-9])
  ICON="􀺸"
  ;;
[3-5][0-9])
  ICON="􀺶"
  ;;
[1-2][0-9])
  ICON="􀛩"
  ;;
*) ICON="􀛪" ;;
esac

# Color speaks: green while charging, red under 20%, text color otherwise.
if [ -n "$CHARGING" ]; then
  ICON="􀋦"
  COLOR=$CHARGE
elif [ "$PERCENTAGE" -le 20 ]; then
  COLOR=$RED
else
  COLOR=$TEXT
fi

sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color=$COLOR label="${PERCENTAGE}%" label.color=$COLOR
