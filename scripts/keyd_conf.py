#!/usr/bin/python3
"""Prepare and atomically install the Vi Resize keyd fragment.

Unprivileged actions read a root-owned /etc/keyd/*.conf, build one bounded
replacement in a user-owned temp, and print that path. The privileged
`install` action (sudo) is the only writer of the system file: same-directory
O_EXCL temp + rename under /etc/keyd.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

from safe_file import MAX_BYTES, atomic_write, die, read_text

BEGIN = "# BEGIN oliverlukschander.vi-resize"
END = "# END oliverlukschander.vi-resize"
KEYD_DIR = Path("/etc/keyd")
CONF_NAME = re.compile(r"^[A-Za-z0-9._-]+\.conf$")


def _cache_path() -> Path:
    cache = Path(os.environ.get("XDG_CACHE_HOME") or (Path.home() / ".cache"))
    return cache / "omarchy-vi-resize" / "keyd.conf.new"


def _has_wildcard(text: str) -> bool:
    return any(line.strip() == "*" for line in text.splitlines())


def _strip_block(text: str) -> str:
    out: list[str] = []
    skipping = False
    for line in text.splitlines(keepends=True):
        stripped = line.rstrip("\r\n")
        if stripped == BEGIN:
            skipping = True
            continue
        if skipping:
            if stripped == END:
                skipping = False
            continue
        out.append(line)
    body = "".join(out).rstrip()
    return body + ("\n" if body else "")


def _with_block(text: str, fragment: str) -> str:
    body = _strip_block(text)
    block = f"{BEGIN}\n{fragment.rstrip()}\n{END}\n"
    if body and not body.endswith("\n"):
        body += "\n"
    if body:
        body += "\n"
    return body + block


def _read_keyd(path: Path) -> str:
    return read_text(path, owner=0)


def _list_conf_names() -> list[str]:
    try:
        names = os.listdir(str(KEYD_DIR))
    except OSError:
        return []
    return [name for name in names if CONF_NAME.match(name)]


def find_wildcard() -> Path | None:
    names = sorted(_list_conf_names(), key=lambda n: (n != "omarchy-vi-mode.conf", n))
    for name in names:
        path = KEYD_DIR / name
        try:
            text = _read_keyd(path)
        except SystemExit:
            continue
        if _has_wildcard(text):
            return path
    return None


def list_managed() -> list[Path]:
    found: list[Path] = []
    for name in _list_conf_names():
        path = KEYD_DIR / name
        try:
            text = _read_keyd(path)
        except SystemExit:
            continue
        if BEGIN in text:
            found.append(path)
    return found


def _write_temp(text: str) -> Path:
    dest = _cache_path()
    if len(text.encode()) > MAX_BYTES:
        die("refusing oversized keyd replacement")
    atomic_write(dest, text)
    return dest


def cmd_find() -> None:
    path = find_wildcard()
    if path is None:
        raise SystemExit(2)
    sys.stdout.write(f"{path}\n")


def cmd_list_managed() -> None:
    for path in list_managed():
        sys.stdout.write(f"{path}\n")


def cmd_prepare(target: Path, fragment_path: Path) -> None:
    current = _read_keyd(target)
    fragment = read_text(fragment_path)
    tmp = _write_temp(_with_block(current, fragment))
    sys.stdout.write(f"{tmp}\n")


def cmd_strip(target: Path) -> None:
    current = _read_keyd(target)
    tmp = _write_temp(_strip_block(current))
    sys.stdout.write(f"{tmp}\n")


def _require_keyd_target(path: Path) -> None:
    if path.parent != KEYD_DIR or not CONF_NAME.match(path.name):
        die(f"refusing keyd target: {path}")


def cmd_install(src: Path, dest: Path) -> None:
    if os.geteuid() != 0:
        die("keyd install must run as root")
    sudo_uid = os.environ.get("SUDO_UID")
    if not sudo_uid or not sudo_uid.isdigit() or int(sudo_uid) <= 0:
        die("refusing install without SUDO_UID")
    _require_keyd_target(dest)
    text = read_text(src, owner=int(sudo_uid))
    atomic_write(dest, text, create_parent=False, owner=0, mode=0o644)


def main(argv: list[str]) -> None:
    if len(argv) < 2:
        die("usage: keyd_conf.py find|list-managed|prepare TARGET FRAGMENT|strip TARGET|install TMP TARGET")
    action = argv[1]
    if action == "find" and len(argv) == 2:
        cmd_find()
    elif action == "list-managed" and len(argv) == 2:
        cmd_list_managed()
    elif action == "prepare" and len(argv) == 4:
        cmd_prepare(Path(argv[2]), Path(argv[3]))
    elif action == "strip" and len(argv) == 3:
        cmd_strip(Path(argv[2]))
    elif action == "install" and len(argv) == 4:
        cmd_install(Path(argv[2]), Path(argv[3]))
    else:
        die("usage: keyd_conf.py find|list-managed|prepare TARGET FRAGMENT|strip TARGET|install TMP TARGET")


if __name__ == "__main__":
    main(sys.argv)
