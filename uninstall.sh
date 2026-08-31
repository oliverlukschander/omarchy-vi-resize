#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOGGLE_DST="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/oliverlukschander-vi-resize.lua"

echo "Removing Omarchy Vi Resize bindings"

rm -f "$TOGGLE_DST"
if command -v hyprctl >/dev/null; then
  hyprctl reload >/dev/null || true
fi

python3 "$PLUGIN_DIR/scripts/menu.py" uninstall
omarchy menu refresh >/dev/null 2>&1 || true

echo "Vi Resize removed. SUPER + J / K / L are back to Omarchy defaults."
echo "SUPER + right-click drag is unchanged."
