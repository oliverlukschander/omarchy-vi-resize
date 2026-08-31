#!/usr/bin/env bash
set -euo pipefail

toggle="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/oliverlukschander-vi-resize.lua"
toggle_present=false
binds_active=false
keyd_mapped=false

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
# SUPER+SHIFT = 65. Plugin is on when SUPER+SHIFT+H resizes.
for bind in binds:
    if bind.get("modmask") == 65 and bind.get("key") == "H":
        print(bind.get("description") or "")
        break
' || true)
fi

if [[ $desc == *"Grow window"* || $desc == *[Rr]esize* ]]; then
  binds_active=true
fi

if grep -qF "BEGIN oliverlukschander.vi-resize" /etc/keyd/*.conf 2>/dev/null; then
  keyd_mapped=true
fi

printf '{"togglePresent":%s,"bindsActive":%s,"keydMapped":%s}\n' \
  "$toggle_present" "$binds_active" "$keyd_mapped"
