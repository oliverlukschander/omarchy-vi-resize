#!/usr/bin/bash
set -euo pipefail

_self=${BASH_SOURCE[0]}
if [[ $_self != /* ]]; then
  _self=${PWD%/}/$_self
fi
PLUGIN_DIR=${_self%/*}
PYTHON=/usr/bin/python3
HYPRCTL=/usr/bin/hyprctl
SUDO=/usr/bin/sudo
KEYD=/usr/bin/keyd
SYSTEMCTL=/usr/bin/systemctl
OMARCHY=/usr/bin/omarchy
HYPR_SRC="$PLUGIN_DIR/hypr/vi-resize.lua"
FRAGMENT="$PLUGIN_DIR/keyd/nav-shift-resize.conf"
TOGGLE_DST="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/oliverlukschander-vi-resize.lua"

echo "Omarchy Vi Resize"
echo "Caps + Shift + hjkl resizes the window (also SUPER + SHIFT + hjkl)."
echo

if [[ ! -x $PYTHON ]]; then
  echo "Missing $PYTHON" >&2
  exit 1
fi
if [[ ! -f $HYPR_SRC ]]; then
  echo "Missing $HYPR_SRC" >&2
  exit 1
fi
if [[ ! -f $FRAGMENT ]]; then
  echo "Missing $FRAGMENT" >&2
  exit 1
fi

run() {
  local timeout=$1 max=$2
  shift 2
  "$PYTHON" -I "$PLUGIN_DIR/scripts/run.py" --timeout "$timeout" --max-stdout "$max" --max-stderr "$max" -- "$@"
}

py() {
  run 15 1048576 "$PYTHON" -I "$@"
}

# Do not wrap sudo in timeout(1). timeout starts a new process group, so sudo
# cannot read a password from the TTY; a 30s deadline also kills a slow prompt.
have_sudo() {
  "$SUDO" -n true >/dev/null 2>&1
}

ensure_sudo() {
  if have_sudo; then
    return 0
  fi
  if [[ ! -t 0 || ! -t 2 ]]; then
    echo "sudo needs a terminal to ask for your password." >&2
    echo "Run: $PLUGIN_DIR/install.sh" >&2
    exit 1
  fi
  echo "Writing /etc/keyd needs root. sudo will ask for your password."
  "$SUDO" -v
}

as_root() {
  ensure_sudo
  "$SUDO" "$PYTHON" -I "$@"
}

reload_keyd() {
  have_sudo || return 0
  "$SUDO" -n "$KEYD" reload >/dev/null 2>&1 || \
    "$SUDO" -n "$SYSTEMCTL" restart keyd >/dev/null 2>&1 || true
}

py "$PLUGIN_DIR/scripts/safe_file.py" copy "$HYPR_SRC" "$TOGGLE_DST"
echo "Wrote $TOGGLE_DST"

if [[ -x $HYPRCTL ]]; then
  run 5 65536 "$HYPRCTL" reload >/dev/null
  errors=$(run 5 65536 "$HYPRCTL" configerrors || true)
  if [[ -n ${errors//[[:space:]]/} ]]; then
    echo "Hyprland config errors:" >&2
    echo "$errors" >&2
  fi
fi

keyd_mapped=false
if [[ -x $KEYD ]]; then
  set +e
  wildcard=$(py "$PLUGIN_DIR/scripts/keyd_conf.py" find)
  find_rc=$?
  set -e
  if [[ $find_rc -eq 0 ]]; then
    echo "Merging Caps+Shift resize into $wildcard"
    echo "(needs Vi Mode's Caps nav layer; keyd allows only one wildcard device config)"
    tmp=$(py "$PLUGIN_DIR/scripts/keyd_conf.py" prepare "$wildcard" "$FRAGMENT")
    as_root "$PLUGIN_DIR/scripts/keyd_conf.py" install "$tmp" "$wildcard"
    reload_keyd
    keyd_mapped=true
  elif [[ $find_rc -eq 2 ]]; then
    echo "No keyd wildcard config found (install Vi Mode for Caps + Shift + hjkl)."
    echo "SUPER + SHIFT + hjkl still resizes without it."
  else
    exit "$find_rc"
  fi
else
  echo "keyd is not installed (install Vi Mode for Caps + Shift + hjkl)."
  echo "SUPER + SHIFT + hjkl still resizes without it."
fi

py "$PLUGIN_DIR/scripts/menu.py" install
if [[ -x $OMARCHY ]]; then
  run 5 65536 "$OMARCHY" menu refresh >/dev/null || true
fi

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
