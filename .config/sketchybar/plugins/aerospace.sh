#!/usr/bin/env bash

# Make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

# Get the app names for the given workspace
WORKSPACE="$1"
APPS=$(aerospace list-windows --workspace "$WORKSPACE" | awk -F'|' 'NF > 1 {gsub(/^ +| +$/, "", $2); gsub(/Microsoft /, "", $2); print $2}' | paste -sd ', ' -)

# Check if APPS is empty and clear the label for empty workspaces
if [ -z "$APPS" ]; then
  sketchybar --set "$NAME" label="$WORKSPACE"
else
  sketchybar --set "$NAME" label="$WORKSPACE:$APPS"
fi

# Set background drawing based on focused workspace
if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "$NAME" background.drawing=on
else
  sketchybar --set "$NAME" background.drawing=off
fi
