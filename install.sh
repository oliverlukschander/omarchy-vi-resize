#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HYPR_SRC="$PLUGIN_DIR/hypr/vi-resize.lua"
FRAGMENT="$PLUGIN_DIR/keyd/nav-shift-resize.conf"
TOGGLE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr"
TOGGLE_DST="$TOGGLE_DIR/oliverlukschander-vi-resize.lua"
KEYD_DIR="/etc/keyd"
BEGIN="# BEGIN oliverlukschander.vi-resize"
END="# END oliverlukschander.vi-resize"

echo "Omarchy Vi Resize"
echo "Caps + Shift + hjkl resizes the window (also SUPER + SHIFT + hjkl)."
echo

if [[ ! -f $HYPR_SRC ]]; then
  echo "Missing $HYPR_SRC" >&2
  exit 1
fi
if [[ ! -f $FRAGMENT ]]; then
  echo "Missing $FRAGMENT" >&2
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

strip_managed_block() {
  local target=$1
  [[ -f $target ]] || return 0
  if grep -qF "$BEGIN" "$target"; then
    sudo sed -i "/$BEGIN/,/$END/d" "$target"
  fi
}

append_managed_block() {
  local target=$1
  strip_managed_block "$target"
  {
    echo
    echo "$BEGIN"
    cat "$FRAGMENT"
    echo "$END"
  } | sudo tee -a "$target" >/dev/null
}

keyd_mapped=false
if pacman -Q keyd &>/dev/null; then
  sudo mkdir -p "$KEYD_DIR"
  wildcard=""
  shopt -s nullglob
  for conf in "$KEYD_DIR"/*.conf; do
    if grep -qE '^[[:space:]]*\*[[:space:]]*$' "$conf"; then
      wildcard=$conf
      break
    fi
  done
  shopt -u nullglob

  if [[ -n $wildcard ]]; then
    echo "Merging Caps+Shift resize into $wildcard"
    echo "(needs Vi Mode's Caps nav layer; keyd allows only one wildcard device config)"
    append_managed_block "$wildcard"
    sudo keyd reload 2>/dev/null || sudo systemctl restart keyd
    keyd_mapped=true
  else
    echo "No keyd wildcard config found (install Vi Mode for Caps + Shift + hjkl)."
    echo "SUPER + SHIFT + hjkl still resizes without it."
  fi
else
  echo "keyd is not installed (install Vi Mode for Caps + Shift + hjkl)."
  echo "SUPER + SHIFT + hjkl still resizes without it."
fi

python3 "$PLUGIN_DIR/scripts/menu.py" install
omarchy menu refresh >/dev/null 2>&1 || true

echo
echo "Ready. Hold Caps + Shift and press:"
echo "  h  grow left"
echo "  j  grow down"
echo "  k  grow up"
echo "  l  grow right"
echo
echo "Same action without Caps: SUPER + SHIFT + hjkl."
echo "SUPER + J / K / L are Omarchy defaults again (split, keybindings, layout)."
echo "SUPER + SHIFT + arrows still swaps windows."
echo "SUPER + right-click drag still resizes with the mouse."
if [[ $keyd_mapped == true ]]; then
  echo
  echo "Caps + Shift + hjkl no longer selects text. Use Shift + arrows for that."
fi
