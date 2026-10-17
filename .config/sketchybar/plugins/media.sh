#!/usr/bin/env bash

# Spotify now-playing. Hides completely when Spotify is not running; the pgrep
# guard also keeps the osascript poll from running for a closed app.
# Click focuses Spotify. Track/artist scroll when too long.

source "$CONFIG_DIR/helpers/theme.sh"

ICON_SPOTIFY=''       # sketchybar-app-font, :spotify:

# Hide or show the whole media island: the bracket and edge spacers must
# follow the item, or an empty pill remains when nothing is playing.
hide_island() {
  sketchybar --set media_island background.drawing=off \
             --set media_r drawing=off \
             --set media drawing=off \
             --set media_l drawing=off
}
show_island() {
  sketchybar --set media_island background.drawing=on \
             --set media_r drawing=on \
             --set media_l drawing=on
}

if ! pgrep -xq Spotify; then
  hide_island
  exit 0
fi

INFO="$(osascript <<'AS' 2>/dev/null
tell application "Spotify"
  if player state is playing then
    artist of current track & " — " & name of current track
  else
    "paused"
  end if
end tell
AS
)"

case "$INFO" in
  "paused")
    # Only playing content is shown; paused Spotify stays hidden.
    hide_island
    ;;
  "")
    hide_island
    ;;
  *)
    show_island
    sketchybar --set media icon="$ICON_SPOTIFY" icon.color=$HA_ON \
      label="$INFO" label.color=$TEXT
    ;;
esac
