# Vi Resize

SUPER + hjkl window resize for Omarchy 4.

There is no first-party Omarchy plugin for this. SUPER + right-click already
drags a resize. This plugin is the keyboard version: hold Super and use
`h` / `j` / `k` / `l` the same way you would move the mouse.

- SUPER + `h` `j` `k` `l` → grow left / down / up / right
- Hold the chord to keep resizing
- SUPER + right-click drag is unchanged

`omarchy plugin add` never runs install hooks, so the bindings are applied by
`install.sh`. No sudo — it only writes a Hyprland toggle.

## Install

Both steps are required — `omarchy plugin add` does not apply Hyprland binds.

```sh
omarchy plugin add https://github.com/oliverlukschander/omarchy-vi-resize.git --enable
~/.config/omarchy/plugins/oliverlukschander.vi-resize/install.sh
```

Click the 󰩨 icon in the bar, or *Setup → Vi Resize* in the Omarchy menu, and
use **Install bindings** if you would rather run that from a floating terminal.

Works next to [Vi Mode](https://github.com/oliverlukschander/omarchy-vi-mode)
and [Mac Option](https://github.com/oliverlukschander/omarchy-mac-option).

## Usage

Hold **Super** and press:

| Keys | Result |
| --- | --- |
| `h` | Grow left |
| `j` | Grow down |
| `k` | Grow up |
| `l` | Grow right |

Tap to nudge. Hold to keep going. SUPER + minus / plus still jumps in larger
steps, and SUPER + right-click still resizes with the mouse.

These Omarchy shortcuts move out of the way:

| Was | Now | Action |
| --- | --- | --- |
| SUPER + J | SUPER + SHIFT + J | Toggle window split |
| SUPER + K | SUPER + SHIFT + K | Keybindings |
| SUPER + L | SUPER + SHIFT + L | Toggle workspace layout |

## Remove

```sh
~/.config/omarchy/plugins/oliverlukschander.vi-resize/uninstall.sh
omarchy plugin remove oliverlukschander.vi-resize
```

Run the uninstaller first. Removing the plugin folder also deletes the
uninstaller.

## License and dependencies

MIT. See [LICENSE](LICENSE).

No extra packages. `install.sh` writes a Hyprland toggle under
`~/.local/state/omarchy/toggles/hypr/` and reloads the compositor. The plugin
itself never runs sudo or install hooks.

Requires **Omarchy 4** (Quattro shell).
