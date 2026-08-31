#!/usr/bin/env bash
set -euo pipefail

toggle="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/oliverlukschander-vi-resize.lua"
toggle_present=false
binds_active=false

if [[ -f $toggle ]]; then
  toggle_present=true
fi

desc=""
if command -v hyprctl >/dev/null && command -v python3 >/dev/null; then
  desc=$(hyprctl binds -j 2>/dev/null | python3 -c '
import json, sys
try:
    binds = json.load(sys.stdin)
except Exception:
    raise SystemExit(0)
for bind in binds:
    if bind.get("modmask") == 64 and bind.get("key") == "H":
        print(bind.get("description") or "")
        break
' || true)
fi

if [[ $desc == *"Grow window"* || $desc == *[Rr]esize* ]]; then
  binds_active=true
fi

printf '{"togglePresent":%s,"bindsActive":%s}\n' "$toggle_present" "$binds_active"
