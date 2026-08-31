#!/usr/bin/env python3
"""Add or remove the Setup → Vi Resize row in the user Omarchy menu."""

from __future__ import annotations

import sys
from pathlib import Path

MENU = Path.home() / ".config/omarchy/extensions/omarchy-menu.jsonc"
MARKER = '"setup.vi-resize"'
ROW = (
    '  "setup.vi-resize": {'
    '"icon":"󰩨",'
    '"label":"Vi Resize",'
    '"description":"SUPER + hjkl resizes the window",'
    '"action":"omarchy-shell shell summon oliverlukschander.vi-resize \'{}\'",'
    '"checked":"test -f ${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr/oliverlukschander-vi-resize.lua"'
    "},\n"
)


def install() -> None:
    MENU.parent.mkdir(parents=True, exist_ok=True)
    text = MENU.read_text() if MENU.exists() else "{\n}\n"
    if MARKER in text:
        return
    idx = text.rfind("}")
    if idx == -1:
        text = "{\n" + ROW + "}\n"
    else:
        text = text[:idx] + ROW + text[idx:]
    MENU.write_text(text)


def uninstall() -> None:
    if not MENU.exists():
        return
    lines = MENU.read_text().splitlines(keepends=True)
    kept = [line for line in lines if MARKER not in line]
    MENU.write_text("".join(kept))


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "install"
    if action == "uninstall":
        uninstall()
    else:
        install()
