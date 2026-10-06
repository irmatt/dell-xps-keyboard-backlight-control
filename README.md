# Dell XPS keyboard backlight control

An [Omarchy](https://omarchy.org) plugin that fixes the Dell keyboard backlight:
the firmware turns it off after an inactivity timeout and, on some models
(notably the XPS 17 9700), does **not** turn it back on when you type or use the
trackpad. This watchdog restores your last level on the next input, and lets you
turn the backlight off with a keybinding when you want it dark.

It runs entirely as your user — no root, no `udev` rule, no Polkit. Brightness is
set through `logind` (`org.freedesktop.login1.Session.SetBrightness`, subsystem
`leds`), which is allowed for the active local session.

## Install

```bash
omarchy plugin add <git-url> --enable
```

Then add this to `~/.config/hypr/bindings.lua` and reload Hyprland:

```lua
o.bind("SUPER + F5", "Keyboard backlight auto-on", "omarchy shell irmatt.kbd-backlight toggle", { locked = true })
```

## Usage

```bash
omarchy shell irmatt.kbd-backlight toggle   # flip auto-on / off  (this is the keybinding)
omarchy shell irmatt.kbd-backlight off      # backlight off; stays off
omarchy shell irmatt.kbd-backlight on       # restore last level; auto-on after idle
omarchy shell irmatt.kbd-backlight status   # {"mode":"auto","level":2,"max":2}
```

- **auto** (default): after the firmware's inactivity off, the next key or
  trackpad event restores your last non-zero level.
- **off**: the backlight is turned off and kept off, even if the firmware or the
  Fn key turns it on.

## Uninstall

```bash
omarchy plugin remove irmatt.kbd-backlight
```

That removes the plugin; the watchdog is a child of the shell and exits with it.
Nothing else is installed.
