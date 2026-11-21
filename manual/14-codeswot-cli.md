# codeswotOS CLI

codeswotOS is usually controlled through the hotkeys and the codeswotOS menu (`Super + Space`). But you can also control it through the `codeswot` CLI. This is particularly helpful when you're having an AI agent work with you on customization or configuration.

The CLI has access to all the internal tooling that is used both via the menu and otherwise. You can see everything that's available by running `codeswot` in the terminal.

It looks something like this:

```
~ ❯ codeswot
codeswotOS command center

Usage:
  codeswot <command> [args...]
  codeswot commands [--all] [--json] [--check]
  codeswot <group> --help
  codeswot <group> <command> --help

Common commands:
  codeswot update              Update codeswotOS and system packages
  codeswot theme list          List available themes
  codeswot theme set <name>    Apply a theme
  codeswot font list           List available fonts
  codeswot screenshot          Take a screenshot
  codeswot debug               Print debugging information

Groups:
  agent          AI coding agent usage data
  audio          Audio input and output controls
  bar            codeswotOS shell bar layout and settings
  battery        Battery status helpers
  bluetooth      Bluetooth device controls
  branch         codeswotOS git branch management
  branding       About and screensaver branding
  brightness     Display and keyboard brightness
  capture        Screenshots and screen recording
  channel        codeswotOS release channel management
  clipboard      Clipboard helpers
  cmd            Command and shortcut helpers
  config         System configuration helpers
  debug          Diagnostics and support logs
  ...
```

And you can dive deeper on every group:

```
~ ❯ codeswot capture
Capture commands — Screenshots and screen recording:
  codeswot capture qr                                                                                                                                                                                                       Decode a QR code from a screenshot region
  codeswot capture screenrecording [--fullscreen] [--with-desktop-audio] [--with-microphone-audio] [--with-webcam] [--webcam-device=<device>] [--webcam-size=<small|medium|large>] [--resolution=<size>] [--stop-recording]  Start or stop screen recording
  codeswot capture screenrecording with webcam                                                                                                                                                                              Pick a webcam and start a screen recording with it
  codeswot capture screenshot [smart|region|windows|fullscreen] [slurp|copy|save] [--editor=<name>]                                                                                                                         Take a screenshot
  codeswot capture text                                                                                                                                                                                                     Extract text from a screenshot region with OCR
  codeswot capture webcam resize <smaller|larger|reset|small|medium|large>                                                                                                                                                  Resize the active webcam recording overlay
```

Every command takes `--help` too, whether you ask a whole group (`codeswot capture --help`) or a single command (`codeswot capture screenshot --help`).

### Opening the menu from the terminal

The codeswotOS menu is scriptable as well, which is handy for your own keybindings. `codeswot menu` opens it at the root, and you can jump straight to any point in the tree by naming it: `codeswot menu summon style.theme` goes right to the theme picker, `codeswot menu toggle system` opens the system menu and closes it again if it's already up, and `codeswot menu close` puts it away.
