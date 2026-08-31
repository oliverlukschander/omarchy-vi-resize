function parseStatus(text) {
  try {
    var obj = JSON.parse(String(text || "").trim())
    return {
      togglePresent: !!obj.togglePresent,
      bindsActive: !!obj.bindsActive
    }
  } catch (e) {
    return { togglePresent: false, bindsActive: false }
  }
}

function ready(status) {
  return !!(status && status.togglePresent && status.bindsActive)
}

function statusLabel(status) {
  if (ready(status)) return "On"
  if (status && status.togglePresent && !status.bindsActive) return "Reload needed"
  return "Off"
}

function statusMeta(status) {
  if (ready(status)) return "SUPER + hjkl resizes the window"
  if (status && status.togglePresent && !status.bindsActive) return "Bindings are installed; reload Hyprland if SUPER + hjkl does nothing"
  return "Install the bindings to turn SUPER + hjkl resize on"
}
