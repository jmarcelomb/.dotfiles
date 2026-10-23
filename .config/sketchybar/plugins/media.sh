#!/usr/bin/env bash
# Spotify now-playing with album art. Mac mini island style.
# Hides completely when Spotify is not running or paused.
# Album art downloaded from Spotify CDN, cached by URL hash.

source "$CONFIG_DIR/helpers/theme.sh"

ART_CACHE="/tmp/sketchybar_spotify_art.png"
ART_URL_CACHE="/tmp/sketchybar_spotify_art_url"

hide_island() {
  sketchybar --set media_island background.drawing=off \
             --set media_r drawing=off \
             --set media drawing=off update_freq=30 \
             --set media_l drawing=off \
             --set gap_ha_media drawing=off
}
show_island() {
  sketchybar --set media_island background.drawing=on \
             --set media_r drawing=on \
             --set media drawing=on update_freq=5 \
             --set media_l drawing=on \
             --set gap_ha_media drawing=on
}

if ! pgrep -xq Spotify; then
  hide_island
  rm -f "$ART_CACHE" "$ART_URL_CACHE" 2>/dev/null
  exit 0
fi

JXA_OUT=$(osascript -l JavaScript -e '
var spotify = Application("Spotify");
if (spotify.playerState() !== "playing") {
  "paused";
} else {
  var t = spotify.currentTrack;
  t.artist() + " — " + t.name() + "\n" + t.artworkUrl();
}
' 2>/dev/null)

case "$JXA_OUT" in
  "paused"|"")
    hide_island
    ;;
  *)
    show_island
    INFO=$(echo "$JXA_OUT" | head -1)
    ART_URL=$(echo "$JXA_OUT" | tail -1)

    PREV_URL=""
    [ -f "$ART_URL_CACHE" ] && PREV_URL=$(cat "$ART_URL_CACHE" 2>/dev/null)
    if [ "$ART_URL" != "$PREV_URL" ]; then
      curl -s -o "$ART_CACHE" "$ART_URL" 2>/dev/null
      if [ -f "$ART_CACHE" ]; then
        # Convert to proper PNG and resize (curl downloads JPEG)
        sips -s format png -z 40 40 "$ART_CACHE" --out "$ART_CACHE" 2>/dev/null
        echo "$ART_URL" > "$ART_URL_CACHE"
      fi
    fi

    if [ -f "$ART_CACHE" ]; then
      sketchybar --set media \
        icon.drawing=on \
        icon.width=20 \
        icon.background.image="$ART_CACHE" \
        icon.background.image.scale=0.5 \
        icon.background.drawing=on \
        icon.background.color=$BAR_BG \
        icon.background.height=20 \
        icon.background.corner_radius=3 \
        icon.background.padding_left=2 \
        icon.background.padding_right=2 \
        label="$INFO" label.color=$TEXT
    else
      sketchybar --set media \
        icon.drawing=off \
        label="$INFO" label.color=$TEXT
    fi
    ;;
esac
