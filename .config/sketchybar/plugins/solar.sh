#!/usr/bin/env bash

# Solar + house load from Deye via Home Assistant, polled once a minute.
# One HA request updates both items. PV watts are computed from the per-string
# voltage x current sensors; load comes straight from the inverter.

source "$CONFIG_DIR/helpers/theme.sh"

GLYPH_SOLAR=''   # fa-solar-panel
GLYPH_HOME='󰋜'     # md-home

set -a
[ -f "$HOME/.hermes/.env" ] && source "$HOME/.hermes/.env"
set +a

read_state() {
  curl -s --max-time 5 -H "Authorization: Bearer $HASS_TOKEN" \
    "$HASS_URL/api/states/$1" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("state", "unavailable"))
except Exception: print("unavailable")' 2>/dev/null
}

PV1_V="$(read_state sensor.inversor_pv1_voltage)"
PV1_A="$(read_state sensor.inversor_pv1_current)"
PV2_V="$(read_state sensor.inversor_pv2_voltage)"
PV2_A="$(read_state sensor.inversor_pv2_current)"
LOAD="$(read_state sensor.inversor_load_power)"

fmt_w() {
  python3 -c "import sys
try:
  w = float('$1')
  print('%.2fkW' % (w / 1000) if abs(w) >= 1000 else '%dW' % round(w))
except Exception: print('-')"
}

if [[ "$PV1_V" =~ ^-?[0-9.]+$ && "$PV1_A" =~ ^-?[0-9.]+$ && "$PV2_V" =~ ^-?[0-9.]+$ && "$PV2_A" =~ ^-?[0-9.]+$ ]]; then
  PV_W="$(python3 -c "print(int(${PV1_V:-0} * ${PV1_A:-0} + ${PV2_V:-0} * ${PV2_A:-0}))")"
  PV_LABEL="$(fmt_w "$PV_W")"
  if [ "${PV_W:-0}" -gt 0 ]; then
    sketchybar --set solar icon.color=$HA_ON label="$PV_LABEL" label.color=$HA_ON
  else
    sketchybar --set solar icon.color=$HA_OFF label="$PV_LABEL" label.color=$DIM
  fi
else
  sketchybar --set solar icon.color=$RED label="" label.color=$TEXT
fi

if [[ "$LOAD" =~ ^-?[0-9.]+$ ]]; then
  sketchybar --set load icon.color=$TEXT label="$(fmt_w "$LOAD")" label.color=$TEXT
else
  sketchybar --set load label="" label.color=$TEXT
fi
