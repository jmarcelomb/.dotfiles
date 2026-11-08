#!/usr/bin/env bash

# Local-model servers pause toggle. Click runs scripts/local-models toggle
# (gates the MLX servers on ~/.local/state/local-models.paused and frees
# ~9 GB of wired GPU memory while paused). State lives in the icon:
# chip glyph, green = running; sleep glyph, dim = paused. The item never
# hides, so no island hide/show handling is needed.

source "$CONFIG_DIR/helpers/theme.sh"

GLYPH_RUN='󰘚'      # md-chip   U+F061A
GLYPH_SLEEP='󰒲'  # md-sleep  U+F04B2
FLAG="$HOME/.local/state/local-models.paused"

if [ "$SENDER" = "mouse.clicked" ]; then
  "$HOME/scripts/local-models" toggle >/dev/null 2>&1 &
  sleep 1
fi

if [ -f "$FLAG" ]; then
  sketchybar --set "$NAME" icon="$GLYPH_SLEEP" icon.color=$HA_OFF
else
  sketchybar --set "$NAME" icon="$GLYPH_RUN" icon.color=$CHARGE
fi
