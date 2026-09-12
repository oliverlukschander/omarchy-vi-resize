#!/usr/bin/python3
"""Bounded status probe for the Vi Resize bar widget."""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

from run import run
from safe_file import read_text

HYPRCTL = "/usr/bin/hyprctl"
BEGIN = "# BEGIN oliverlukschander.vi-resize"
TIMEOUT_SEC = 2
MAX_STDOUT = 256 * 1024
MAX_STDERR = 64 * 1024


def _exists_regular(path: Path) -> bool:
    try:
        read_text(path)
        return True
    except SystemExit:
        return False
    except OSError:
        return False


def _hyprctl_resize_desc() -> str:
    code, stdout, _stderr = run(
        [HYPRCTL, "binds", "-j"],
        timeout=TIMEOUT_SEC,
        max_stdout=MAX_STDOUT,
        max_stderr=MAX_STDERR,
    )
    if code != 0:
        return ""
    try:
        binds = json.loads(stdout.decode())
    except (ValueError, UnicodeDecodeError):
        return ""
    if not isinstance(binds, list):
        return ""
    for bind in binds:
        if not isinstance(bind, dict):
            continue
        if bind.get("modmask") == 65 and bind.get("key") == "H":
            desc = bind.get("description") or ""
            return desc if isinstance(desc, str) else ""
    return ""


def _keyd_mapped() -> bool:
    try:
        names = os.listdir("/etc/keyd")
    except OSError:
        return False
    for name in names:
        if not name.endswith(".conf") or name.startswith("."):
            continue
        try:
            text = read_text(Path("/etc/keyd") / name, owner=0)
        except SystemExit:
            continue
        if BEGIN in text:
            return True
    return False


def main() -> None:
    state_home = Path(os.environ.get("XDG_STATE_HOME") or (Path.home() / ".local/state"))
    toggle = state_home / "omarchy" / "toggles" / "hypr" / "oliverlukschander-vi-resize.lua"
    toggle_present = _exists_regular(toggle)
    desc = _hyprctl_resize_desc()
    binds_active = "Grow window" in desc or "esize" in desc
    sys.stdout.write(
        json.dumps(
            {
                "togglePresent": toggle_present,
                "bindsActive": binds_active,
                "keydMapped": _keyd_mapped(),
            },
            separators=(",", ":"),
        )
        + "\n"
    )


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.stdout.write('{"togglePresent":false,"bindsActive":false,"keydMapped":false}\n')
        raise SystemExit(0)
