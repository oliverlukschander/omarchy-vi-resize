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
TIMEOUT=/usr/bin/timeout
TOGGLE_DST="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/oliverlukschander-vi-resize.lua"

echo "Removing Omarchy Vi Resize bindings"

if [[ ! -x $PYTHON ]]; then
  echo "Missing $PYTHON" >&2
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

as_root() {
  if [[ -x $TIMEOUT ]]; then
    "$TIMEOUT" 30 "$SUDO" "$PYTHON" -I "$@"
  else
    "$SUDO" "$PYTHON" -I "$@"
  fi
}

py "$PLUGIN_DIR/scripts/safe_file.py" remove "$TOGGLE_DST"
if [[ -x $HYPRCTL ]]; then
  run 5 65536 "$HYPRCTL" reload >/dev/null || true
fi

if [[ -x $KEYD ]]; then
  did_keyd=false
  while IFS= read -r target; do
    [[ -n $target ]] || continue
    tmp=$(py "$PLUGIN_DIR/scripts/keyd_conf.py" strip "$target")
    as_root "$PLUGIN_DIR/scripts/keyd_conf.py" install "$tmp" "$target"
    did_keyd=true
  done < <(py "$PLUGIN_DIR/scripts/keyd_conf.py" list-managed || true)
  if [[ $did_keyd == true ]]; then
    if [[ -x $TIMEOUT ]]; then
      "$TIMEOUT" 8 "$SUDO" "$KEYD" reload >/dev/null 2>&1 || "$TIMEOUT" 8 "$SUDO" "$SYSTEMCTL" restart keyd >/dev/null 2>&1 || true
    else
      "$SUDO" "$KEYD" reload >/dev/null 2>&1 || "$SUDO" "$SYSTEMCTL" restart keyd >/dev/null 2>&1 || true
    fi
  fi
fi

py "$PLUGIN_DIR/scripts/menu.py" uninstall
if [[ -x $OMARCHY ]]; then
  run 5 65536 "$OMARCHY" menu refresh >/dev/null || true
fi

echo "Vi Resize removed. SUPER + J / K / L stay on Omarchy defaults."
echo "Caps + Shift + hjkl is back to Shift + arrows if Vi Mode is on."
echo "SUPER + right-click drag is unchanged."
