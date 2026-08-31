function parseStatus(text) {
  try {
    var obj = JSON.parse(String(text || "").trim())
    return {
      togglePresent: !!obj.togglePresent,
      bindsActive: !!obj.bindsActive,
      keydMapped: !!obj.keydMapped
    }
  } catch (e) {
    return { togglePresent: false, bindsActive: false, keydMapped: false }
  }
}

function ready(status) {
  return !!(status && status.togglePresent && status.bindsActive)
}

function statusLabel(status) {
  if (ready(status) && status.keydMapped) return "On"
  if (ready(status)) return "Super only"
  if (status && status.togglePresent && !status.bindsActive) return "Reload needed"
  return "Off"
}

function statusMeta(status) {
  if (ready(status) && status.keydMapped) return "Caps + Shift + hjkl resizes the window"
  if (ready(status)) return "SUPER + SHIFT + hjkl resizes; install Vi Mode for Caps + Shift"
  if (status && status.togglePresent && !status.bindsActive) return "Bindings are installed; reload Hyprland if resize does nothing"
  return "Install the bindings to turn Caps + Shift + hjkl resize on"
}
