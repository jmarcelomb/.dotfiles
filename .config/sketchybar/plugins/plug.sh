#!/usr/bin/env bash

# Mac mini wall-plug toggle via Home Assistant. WARNING: switching this off
# cuts power to the machine the bar runs on (hard shutdown when used locally).
# Reads HASS_URL / HASS_TOKEN from ~/.hermes/.env at runtime.

source "$CONFIG_DIR/helpers/theme.sh"

ENTITY="switch.sala_tomada_mac_mini"
GLYPH_PLUG='󰐧'   # md-power_socket

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
  sketchybar --set "$NAME" icon="$GLYPH_PLUG" icon.color=$DIM
  if [ "$STATE" = "on" ]; then SVC="turn_off"; else SVC="turn_on"; fi
  ha "/api/services/switch/$SVC" -X POST -d "{\"entity_id\": \"$ENTITY\"}" > /dev/null
  sleep 1
  STATE="$(ha "/api/states/$ENTITY" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("state", "unavailable"))
except Exception: print("unavailable")' 2>/dev/null)"
fi

# Power drawn through the plug, shown as the item label.
P="$(ha "/api/states/sensor.sala_tomada_mac_mini_potencia" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("state", ""))
except Exception: print("")' 2>/dev/null)"
if [[ "$P" =~ ^-?[0-9.]+$ ]]; then
  LABEL="$(python3 -c "
w = float('$P')
print('%.2fkW' % (w / 1000) if w >= 1000 else '%dW' % round(w))")"
  sketchybar --set "$NAME" label="$LABEL" label.color=$TEXT
else
  sketchybar --set "$NAME" label="" label.color=$TEXT
fi

case "$STATE" in
  on)  sketchybar --set "$NAME" icon="$GLYPH_PLUG" icon.color=$HA_ON ;;
  off) sketchybar --set "$NAME" icon="$GLYPH_PLUG" icon.color=$HA_OFF ;;
  *)   sketchybar --set "$NAME" icon="$GLYPH_PLUG" icon.color=$RED ;;
esac
