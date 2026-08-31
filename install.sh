#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_SRC="$PLUGIN_DIR/hypr/vi-resize.lua"
TOGGLE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr"
TOGGLE_DST="$TOGGLE_DIR/oliverlukschander-vi-resize.lua"

echo "Omarchy Vi Resize"
echo "SUPER + h/j/k/l resizes the window. Hold to keep going."
echo

if [[ ! -f $HYPR_SRC ]]; then
  echo "Missing $HYPR_SRC" >&2
  exit 1
fi

mkdir -p "$TOGGLE_DIR"
install -m 644 "$HYPR_SRC" "$TOGGLE_DST"
echo "Wrote $TOGGLE_DST"

if command -v hyprctl >/dev/null; then
  hyprctl reload >/dev/null
  errors=$(hyprctl configerrors 2>/dev/null || true)
  if [[ -n ${errors//[[:space:]]/} ]]; then
    echo "Hyprland config errors:" >&2
    echo "$errors" >&2
  fi
fi

python3 "$PLUGIN_DIR/scripts/menu.py" install
omarchy menu refresh >/dev/null 2>&1 || true

echo
echo "Ready. Hold Super and press:"
echo "  h  grow left"
echo "  j  grow down"
echo "  k  grow up"
echo "  l  grow right"
echo
echo "SUPER + right-click drag still resizes with the mouse."
echo
echo "These Omarchy shortcuts moved:"
echo "  SUPER + SHIFT + J  toggle split   (was SUPER + J)"
echo "  SUPER + SHIFT + K  keybindings    (was SUPER + K)"
echo "  SUPER + SHIFT + L  workspace layout (was SUPER + L)"
