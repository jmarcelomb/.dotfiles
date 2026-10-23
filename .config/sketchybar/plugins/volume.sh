#!/bin/sh

# Volume with mute toggle. Clicking the item toggles mute; the icon renders
# from the live system state (volume_change events, clicks, wake).

source "$CONFIG_DIR/helpers/theme.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  osascript -e 'set volume output muted not (output muted of (get volume settings))' >/dev/null
fi

READ="$(osascript -e 'get volume settings' 2>/dev/null)"
VOLUME="$(echo "$READ" | sed -n 's/.*output volume:\([0-9]*\).*/\1/p')"
MUTED="$(echo "$READ" | grep -q 'output muted:true' && echo 1)"

if [ "$MUTED" = "1" ]; then
  ICON="􀊜"
elif [ "$VOLUME" -ge 60 ]; then
  ICON="􀊨"
elif [ "$VOLUME" -ge 30 ]; then
  ICON="􀊦"
elif [ "$VOLUME" -ge 1 ]; then
  ICON="􀊤"
else
  ICON="􀊣"
fi

if [ "$MUTED" = "1" ]; then
  LABEL="muted"
else
  LABEL="${VOLUME}%"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color=$TEXT label="$LABEL" label.color=$TEXT
