#!/usr/bin/env bash

# Candeeiro (desk lamp) toggle via Home Assistant. Reads HASS_URL / HASS_TOKEN
# from ~/.hermes/.env at runtime; the token never lives in this repo.
# Click the item to toggle, the dot shows the state.

ENTITY="light.sala_candeeiro_secretaria_pessoal"

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
  on)  sketchybar --set "$NAME" icon="●" icon.color=0xffe6c34a ;;
  off) sketchybar --set "$NAME" icon="●" icon.color=0xff666666 ;;
  *)   sketchybar --set "$NAME" icon="✕" icon.color=0xffcc5555 ;;
esac
