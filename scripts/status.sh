#!/usr/bin/env bash
set -euo pipefail

toggle="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/oliverlukschander-vi-resize.lua"
toggle_present=false
binds_active=false

if [[ -f $toggle ]]; then
  toggle_present=true
fi

if command -v hyprctl >/dev/null && command -v python3 >/dev/null; then
  if hyprctl binds -j 2>/dev/null | python3 -c '
import json, sys
try:
    binds = json.load(sys.stdin)
except Exception:
    sys.exit(1)
# SUPER = 64. Plugin is on when SUPER+H resizes.
for bind in binds:
    if bind.get("modmask") == 64 and bind.get("key") == "H":
        desc = (bind.get("description") or "").lower()
        if "grow window" in desc or "resize" in desc:
            sys.exit(0)
sys.exit(1)
' then
    binds_active=true
  fi
fi

printf '{"togglePresent":%s,"bindsActive":%s}\n' "$toggle_present" "$binds_active"
