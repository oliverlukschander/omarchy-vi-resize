-- SUPER + hjkl resizes the active window, repeating while held.
-- Same dispatcher as SUPER + minus/plus, mapped onto vim directions.
--
-- Takes SUPER + J / K / L from Omarchy defaults. Those actions move to
-- SUPER + SHIFT + J / K / L. SUPER + right-click drag is unchanged.

local step = 40
local opts = { repeating = true }

hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")

o.bind("SUPER + H", "Grow window left", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), opts)
o.bind("SUPER + J", "Grow window down", hl.dsp.window.resize({ x = 0, y = step, relative = true }), opts)
o.bind("SUPER + K", "Grow window up", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), opts)
o.bind("SUPER + L", "Grow window right", hl.dsp.window.resize({ x = step, y = 0, relative = true }), opts)

o.bind("SUPER + SHIFT + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + SHIFT + K", "Keybindings", "omarchy-menu-keybindings")
o.bind("SUPER + SHIFT + L", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
