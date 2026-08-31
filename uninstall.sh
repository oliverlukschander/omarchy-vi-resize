#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOGGLE_DST="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/oliverlukschander-vi-resize.lua"
KEYD_DIR="/etc/keyd"
BEGIN="# BEGIN oliverlukschander.vi-resize"
END="# END oliverlukschander.vi-resize"

echo "Removing Omarchy Vi Resize bindings"

rm -f "$TOGGLE_DST"
if command -v hyprctl >/dev/null; then
  hyprctl reload >/dev/null || true
fi

if [[ -d $KEYD_DIR ]]; then
  shopt -s nullglob
  for conf in "$KEYD_DIR"/*.conf; do
    if grep -qF "$BEGIN" "$conf"; then
      sudo sed -i "/$BEGIN/,/$END/d" "$conf"
    fi
  done
  shopt -u nullglob
  if systemctl is-active --quiet keyd; then
    sudo keyd reload 2>/dev/null || sudo systemctl restart keyd
  fi
fi

python3 "$PLUGIN_DIR/scripts/menu.py" uninstall
omarchy menu refresh >/dev/null 2>&1 || true

echo "Vi Resize removed. SUPER + J / K / L stay on Omarchy defaults."
echo "Caps + Shift + hjkl is back to Shift + arrows if Vi Mode is on."
echo "SUPER + right-click drag is unchanged."
