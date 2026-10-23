#!/usr/bin/env bash
# Extract real app icons from ALL apps in /Applications and /System/Applications.
# Uses NSWorkspace via JXA to get the actual icon macOS displays, including
# from Assets.car catalogs. No hardcoded app list - discovers everything.
# Saves 40x40 PNGs to ~/.dotfiles/.config/sketchybar/icons/
# Run on the host: bash extract_icons_auto.sh

ICONS_DIR="$HOME/.dotfiles/.config/sketchybar/icons"
mkdir -p "$ICONS_DIR"
JXA_SCRIPT="$HOME/Code/extract_icon.jxa"

# Find all .app bundles in common locations
APPS=$(find /Applications /System/Applications /System/Applications/Utilities \
       -maxdepth 2 -name "*.app" -prune 2>/dev/null | sort)

echo "Auto-discovering apps and extracting icons to $ICONS_DIR ..."
echo ""

extract_icon() {
  local bundle_path="$1"
  # Get the app name from the bundle directory name
  local app_name=$(basename "$bundle_path" .app)
  local safe_name
  safe_name=$(echo "$app_name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
  local output="$ICONS_DIR/${safe_name}.png"
  local tmp_png="/tmp/icon_jxa_${safe_name}.png"

  # Skip if already extracted and newer than the bundle
  if [ -f "$output" ] && [ "$output" -nt "$bundle_path" ]; then
    echo "SKIP: $app_name (already up to date)"
    return
  fi

  result=$(osascript -l JavaScript "$JXA_SCRIPT" "$bundle_path" "$tmp_png" 2>&1)

  if [ ! -f "$tmp_png" ]; then
    echo "FAIL: $app_name (JXA extraction failed: $result)"
    return
  fi

  sips -z 40 40 "$tmp_png" --out "$output" 2>/dev/null
  rm -f "$tmp_png"

  if [ -f "$output" ]; then
    echo "OK: $app_name -> ${safe_name}.png"
  else
    echo "FAIL: $app_name (sips resize failed)"
  fi
}

count=0
echo "$APPS" | while IFS= read -r app_path; do
  [ -z "$app_path" ] && continue
  extract_icon "$app_path"
  count=$((count + 1))
done

echo ""
echo "Done. $(ls -1 "$ICONS_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ') icons in $ICONS_DIR"
