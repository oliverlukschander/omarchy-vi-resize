# Vi Resize

Caps + Shift + hjkl window resize for Omarchy 4.

There is no first-party Omarchy plugin for this. SUPER + right-click already
drags a resize. This plugin is the keyboard version on the Vi Mode layer:
hold Caps + Shift and use `h` / `j` / `k` / `l` the same way you would move
the mouse.

- Caps + Shift + `h` `j` `k` `l` → grow left / down / up / right
- SUPER + SHIFT + `h` `j` `k` `l` does the same without Caps
- Hold the chord to keep resizing
- SUPER + right-click drag is unchanged
- SUPER + J / K / L stay on Omarchy defaults (split, keybindings, layout)

`omarchy plugin add` never runs install hooks, so the bindings are applied by
`install.sh`.

## Install

Both steps are required — `omarchy plugin add` cannot run sudo.

```sh
omarchy plugin add https://github.com/oliverlukschander/omarchy-vi-resize.git --enable
~/.config/omarchy/plugins/oliverlukschander.vi-resize/install.sh
```

`install.sh` writes a Hyprland toggle for SUPER + SHIFT + hjkl (no sudo), then
asks for sudo to merge Caps + Shift + hjkl into the Vi Mode keyd config.

Click the 󰩨 icon in the bar, or *Setup → Vi Resize* in the Omarchy menu, and
use **Install bindings** if you would rather run that from a floating terminal.

Works next to [Vi Mode](https://github.com/oliverlukschander/omarchy-vi-mode)
and [Mac Option](https://github.com/oliverlukschander/omarchy-mac-option).
Caps + Shift + hjkl needs Vi Mode's Caps nav layer. SUPER + SHIFT + hjkl
still resizes without it. keyd only allows one wildcard device config, so
this plugin merges into `/etc/keyd/omarchy-vi-mode.conf` when that file is
present.

## Usage

Hold **Caps + Shift** and press:

| Keys | Result |
| --- | --- |
| `h` | Grow left |
| `j` | Grow down |
| `k` | Grow up |
| `l` | Grow right |

Tap to nudge. Hold to keep going. SUPER + SHIFT + hjkl is the same action
without Caps. SUPER + minus / plus still jumps in larger steps, and SUPER +
right-click still resizes with the mouse.

Do not use SUPER + SHIFT + Caps + hjkl for resize. Caps + hjkl already sends
arrow keys, so that chord is SUPER + SHIFT + arrows, which **swaps** windows.

Caps + Shift + hjkl no longer selects text. Use Shift + arrows for that.

## Remove

```sh
~/.config/omarchy/plugins/oliverlukschander.vi-resize/uninstall.sh
omarchy plugin remove oliverlukschander.vi-resize
```

Run the uninstaller first. Removing the plugin folder also deletes the
uninstaller.

## License and dependencies

MIT. See [LICENSE](LICENSE).

Hyprland binds need no extra packages. Caps + Shift + hjkl needs
[keyd](https://github.com/rvaiya/keyd) and Vi Mode. `install.sh` writes a
Hyprland toggle under `~/.local/state/omarchy/toggles/hypr/`, then asks for
sudo to merge the keyd fragment. The plugin itself never runs sudo or install
hooks.

Requires **Omarchy 4** (Quattro shell).
