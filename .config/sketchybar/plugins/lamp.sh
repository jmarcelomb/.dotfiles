#!/usr/bin/env bash

# Candeeiro (desk lamp) toggle via Home Assistant. Reads HASS_URL / HASS_TOKEN
# from ~/.hermes/.env at runtime; the token never lives in this repo.
# Click the item to toggle. The desk-lamp glyph carries the state in its
# color: warm yellow = on, dim gray = off, red alert glyph = unreachable.

ENTITY="light.sala_candeeiro_secretaria_pessoal"
GLYPH_LAMP=$'\U000F095F'      # md-desk_lamp
GLYPH_ALERT=$'\U000F19E1'     # md-lightbulb_alert

set -a
[ -f "$HOME/.hermes/.env" ] && source "$HOME/.hermes/.env"
set +a

ha() {
  curl -s --max-time 5 \
    -H "Authorization: Bearer $HASS_TOKEN" \
    -H "Content-Type: application/json" \
    "$HASS_URL$1" "${@:2}"
}

STATE="$(ha "/api/states/$ENTITY" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("state", "unavailable"))
except Exception: print("unavailable")' 2>/dev/null)"

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$STATE" = "on" ]; then SVC="turn_off"; else SVC="turn_on"; fi
  ha "/api/services/light/$SVC" -X POST -d "{\"entity_id\": \"$ENTITY\"}" > /dev/null
  sleep 1
  STATE="$(ha "/api/states/$ENTITY" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("state", "unavailable"))
except Exception: print("unavailable")' 2>/dev/null)"
fi

case "$STATE" in
  on)  sketchybar --set "$NAME" icon="$GLYPH_LAMP" icon.color=0xffe6c34a ;;
  off) sketchybar --set "$NAME" icon="$GLYPH_LAMP" icon.color=0xff777777 ;;
  *)   sketchybar --set "$NAME" icon="$GLYPH_ALERT" icon.color=0xffcc5555 ;;
esac
