import QtQuick
import Quickshell
import Quickshell.Io

// Runs the keyboard-backlight watchdog as a long-lived child of the shell and
// exposes an IPC target. Control it with:
//
//   omarchy shell irmatt.kbd-backlight toggle
//   omarchy shell irmatt.kbd-backlight off
//   omarchy shell irmatt.kbd-backlight on
//   omarchy shell irmatt.kbd-backlight status
Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  readonly property string home: Quickshell.env("HOME")
  readonly property string pluginDir: home + "/.config/omarchy/plugins/irmatt.kbd-backlight"
  readonly property string stateDir: home + "/.local/state/omarchy/kbd-backlight-autorestore"
  readonly property string statusPath: stateDir + "/status.json"

  // The watchdog runs for as long as the plugin is loaded. Restart it if it
  // ever exits so auto-on keeps working across daemon hiccups.
  Process {
    id: daemon
    command: ["python3", root.pluginDir + "/bin/kbd-backlight-daemon"]
    running: true
    onExited: function(exitCode, exitStatus) {
      console.log("kbd-backlight: watchdog exited (" + exitCode + "); restarting")
      restartTimer.restart()
    }
  }

  Timer {
    id: restartTimer
    interval: 1500
    repeat: false
    onTriggered: if (!daemon.running) daemon.running = true
  }

  // Latest status written by the watchdog (or by kbd-backlight-control).
  FileView {
    id: statusFile
    path: root.statusPath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
  }

  Process {
    id: control
    onExited: function(exitCode, exitStatus) { statusFile.reload() }
  }

  function runControl(action) {
    if (control.running) return
    control.command = [root.pluginDir + "/bin/kbd-backlight-control", action]
    control.running = true
  }

  IpcHandler {
    target: "irmatt.kbd-backlight"

    function status(): string {
      var text = String(statusFile.text() || "").trim()
      return text.length ? text : "{}"
    }

    function on(): string {
      root.runControl("on")
      return "on"
    }

    function off(): string {
      root.runControl("off")
      return "off"
    }

    function toggle(): string {
      root.runControl("toggle")
      return "toggle"
    }
  }
}
