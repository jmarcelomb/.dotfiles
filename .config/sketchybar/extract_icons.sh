#!/usr/bin/env bash
# Extract real app icons from macOS app bundles for sketchybar.
# Mac mini version. Uses NSWorkspace via JXA to get the real icon
# from Assets.car, not just the .icns fallback.
# Saves 40x40 PNGs to ~/.dotfiles/.config/sketchybar/icons/

ICONS_DIR="$HOME/.dotfiles/.config/sketchybar/icons"
mkdir -p "$ICONS_DIR"
JXA_SCRIPT="$HOME/Code/extract_icon.jxa"

# Map: app_name (as AeroSpace reports it) | bundle_path
APPS=(
  "Google Chrome|/Applications/Google Chrome.app"
  "Safari|/Applications/Safari.app"
  "Ghostty|/Applications/Ghostty.app"
  "Zen|/Applications/Zen.app"
  "Bitwarden|/Applications/Bitwarden.app"
  "Spotify|/Applications/Spotify.app"
  "Element|/Applications/Element.app"
  "Joplin|/Applications/Joplin.app"
  "Messenger|/Applications/Messenger.app"
  "WhatsApp|/Applications/WhatsApp.app"
  "OBS|/Applications/OBS.app"
  "OrbStack|/Applications/OrbStack.app"
  "Discord|/Applications/Discord.app"
  "Telegram|/Applications/Telegram.app"
  "VLC|/Applications/VLC.app"
  "Visual Studio Code|/Applications/Visual Studio Code.app"
  "Zed|/Applications/Zed.app"
  "ChatGPT|/Applications/ChatGPT.app"
  "Raycast|/Applications/Raycast.app"
  "NetBird|/Applications/NetBird.app"
  "Hermes|/Applications/Hermes.app"
  "Transmission|/Applications/Transmission.app"
  "Orion|/Applications/Orion.app"
  "VeraCrypt|/Applications/VeraCrypt.app"
  "Shottr|/Applications/Shottr.app"
  "KeyCastr|/Applications/KeyCastr.app"
)

echo "Extracting real app icons via NSWorkspace to $ICONS_DIR ..."
echo ""

for entry in "${APPS[@]}"; do
  app_name="${entry%%|*}"
  bundle_path="${entry#*|}"
  safe_name=$(echo "$app_name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
  output="$ICONS_DIR/${safe_name}.png"
  tmp_png="/tmp/icon_jxa_${safe_name}.png"

  if [ ! -d "$bundle_path" ]; then
    echo "SKIP: $app_name (bundle not found: $bundle_path)"
    continue
  fi

  result=$(osascript -l JavaScript "$JXA_SCRIPT" "$bundle_path" "$tmp_png" 2>&1)

  if [ ! -f "$tmp_png" ]; then
    echo "FAIL: $app_name (JXA extraction failed: $result)"
    continue
  fi

  sips -z 40 40 "$tmp_png" --out "$output" 2>/dev/null
  rm -f "$tmp_png"

  if [ -f "$output" ]; then
    echo "OK: $app_name -> ${safe_name}.png"
  else
    echo "FAIL: $app_name (sips resize failed)"
  fi
done

echo ""
echo "Done. $(ls -1 "$ICONS_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ') icons in $ICONS_DIR"
