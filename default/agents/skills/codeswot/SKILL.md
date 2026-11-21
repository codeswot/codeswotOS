---
name: codeswot
description: >
  REQUIRED for end-user customization of Linux desktop, window manager, or system config.
  Use when editing ~/.config/hypr/, ~/.config/codeswot/,
  ~/.config/alacritty/, ~/.config/foot/, ~/.config/kitty/, or ~/.config/ghostty/.
  Triggers: Hyprland, window rules, animations, keybindings, monitors, gaps, borders,
  blur, opacity, codeswot-shell, bar, terminal config, themes, background,
  night light, idle, lock screen, screenshots, reminders, layer rules, workspace
  settings, display config, and user-facing codeswot commands. Excludes codeswotOS
  source development through `codeswot dev link` workflows.
---

# codeswotOS Skill

Manage [codeswotOS](https://omarchy.org/) Linux systems - a beautiful, modern, opinionated Arch Linux distribution with Hyprland.

This skill is for end-user customization on installed systems.
It is not for contributing to codeswotOS source code.

## When This Skill MUST Be Used

**ALWAYS invoke this skill for end-user requests involving ANY of these:**

- Editing ANY file in `~/.config/hypr/` (window rules, animations, keybindings, monitors, etc.)
- Editing `~/.config/codeswot/shell.json` (status bar layout, widgets)
- Editing terminal configs (alacritty, foot, kitty, ghostty)
- Editing ANY file in `~/.config/codeswot/`
- Window behavior, animations, opacity, blur, gaps, borders
- Layer rules, workspace settings, display/monitor configuration
- Themes, backgrounds, fonts, appearance changes
- User-facing `codeswot` commands (`codeswot theme ...`, `codeswot refresh ...`, `codeswot restart ...`, etc.)
- Screenshots, screen recording, reminders, night light, idle behavior, lock screen

**If you're about to edit a config file in ~/.config/ on this system, STOP and use this skill first.**

**Do NOT use this skill for codeswotOS development tasks** (editing the codeswotOS source tree, creating migrations, or running `codeswot dev ...` workflows).

## Topic Guides

Deeper instructions for common areas live next to this file. Read the
matching guide before starting:

- [`hyprland.md`](hyprland.md) - keybindings, monitors, window rules, and other Hyprland config
- [`plugins.md`](plugins.md) - the codeswotOS shell: bar layout, widgets, plugins, idle behavior
- [`theming.md`](theming.md) - themes, backgrounds, and fonts
- [`hooks.md`](hooks.md) - automation hooks that run on system events
- [`capture.md`](capture.md) - screenshots, screen recordings, OCR text capture, and file sharing
- [`contributing.md`](contributing.md) - reporting codeswotOS bugs and submitting fixes upstream

## Critical Safety Rules

For privileged commands, follow the Privilege Escalation rules below: `sudo` when a terminal is available for the password prompt, `pkexec` when it is not. Do not wrap commands that already manage privilege elevation themselves.

**For end-user customization tasks, NEVER modify anything in `/usr/share/codeswot/`** - but READING is safe and encouraged.

This directory is owned by the codeswot package. Any local changes will be
overwritten on the next `codeswot update`.

```
/usr/share/codeswot/     # READ-ONLY - NEVER EDIT (reading is OK)
├── bin/                    # Command source (packaged binaries are on PATH)
├── config/                 # Default config templates
├── themes/                 # Stock themes
├── default/                # System defaults
├── shell/                  # codeswotOS shell source and defaults
├── migrations/             # Update migrations
└── install/                # Installation scripts
```

**Reading `/usr/share/codeswot/` is SAFE and useful** - do it freely to:
- Understand how codeswot commands work: `codeswot theme set --help` or `cat $(which codeswot-theme-set)`
- See default configs before customizing: `cat "$CODESWOT_PATH/config/codeswot/shell.json"`
- Check stock theme files to copy for customization
- Reference default hyprland settings: `cat /usr/share/codeswot/default/hypr/*`

**Always use these safe locations instead:**
- `~/.config/` - User configuration (safe to edit)
- `~/.config/codeswot/themes/<custom-name>/` - Custom themes
- `~/.config/codeswot/hooks/` - Custom automation hooks

If the request is to develop codeswotOS itself, this skill is out of scope. Follow repository development instructions instead of this skill.

## Privilege Escalation

For an interactive script or command run in a visible terminal, use `sudo` for
privileged work. codeswotOS may grant passwordless `sudo` access to particular
commands, and the terminal is the appropriate place to request a password
when one is needed.

Use `pkexec` only when the caller cannot interact with a terminal or cannot
enter a password there, such as a command launched by an agent or a graphical
background process. Do not replace `sudo` with `pkexec` merely because a
command changes system state.

## System Architecture

codeswotOS is built on:

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor/WM | `~/.config/hypr/` |
| **codeswotOS shell** | Status bar + notifications (Quickshell) | `~/.config/codeswot/shell.json` |
| **Launcher/menus** | Quickshell menu | `~/.config/codeswot/extensions/codeswot-menu.jsonc` |
| **Alacritty/Foot/Kitty/Ghostty** | Terminals | `~/.config/<terminal>/` |
| **codeswotOS OSD** | On-screen display | Quickshell plugin |

## Command Discovery

codeswotOS ships a single `codeswot` CLI that dispatches to all `codeswot-*` binaries via `codeswot <group> <action>`. Always prefer this form — it is self-documenting and stable. The underlying `codeswot-*` binaries still exist on `PATH` and remain safe to read for source.

```bash
# List every documented command and its summary (--all includes hidden commands)
codeswot commands

# Show the commands inside a group
codeswot theme --help
codeswot refresh --help
codeswot restart --help

# Show help for a specific command (does not execute it)
codeswot theme set --help

# Machine-readable listing (binary, route, summary, args, aliases)
codeswot commands --json

# Read a command's source to understand it
cat $(which codeswot-theme-set)
```

### Command Groups

Run `codeswot --help` for the full list. The most common groups:

| Group | Purpose | Example |
|-------|---------|---------|
| `codeswot refresh` | Reset config to defaults (backs up first) | `codeswot refresh shell` |
| `codeswot restart` | Restart a service/app | `codeswot restart shell` |
| `codeswot toggle` | Toggle feature on/off | `codeswot toggle nightlight` |
| `codeswot theme` | Theme management | `codeswot theme set <name>` |
| `codeswot bar` | Bar layout and widgets | `codeswot bar move omarchy.clock --section right` |
| `codeswot plugin` | Manage/clone shell plugins | `codeswot plugin clone omarchy.clock` |
| `codeswot hook` | Install automation hooks | `codeswot hook install theme-set <script>` |
| `codeswot install` | Install optional software / packages | `codeswot install docker dbs` |
| `codeswot launch` | Launch apps | `codeswot launch browser` |
| `codeswot capture` | Screenshots and recordings | `codeswot capture screenshot` |
| `codeswot reminder` | Desktop notification reminders | `codeswot reminder 15 "Pickup Jack"` |
| `codeswot pkg` | Package management | `codeswot pkg add <pkg>` |
| `codeswot setup` | Interactive setup wizards | `codeswot setup security fingerprint` |
| `codeswot update` | System updates | `codeswot update` |

## Configuration Locations

Hyprland config lives in `~/.config/hypr/` — see [`hyprland.md`](hyprland.md).
The codeswotOS shell (bar, notifications, plugins, idle) is configured in
`~/.config/codeswot/shell.json` — see [`plugins.md`](plugins.md).

### Terminals

```
~/.config/alacritty/alacritty.toml
~/.config/foot/foot.ini
~/.config/kitty/kitty.conf
~/.config/ghostty/config
```

**Command:** `codeswot restart terminal`

### Other Configs

| App | Location |
|-----|----------|
| btop | `~/.config/btop/btop.conf` |
| fastfetch | `/etc/fastfetch/config.jsonc` default; `~/.config/fastfetch/config.jsonc` user override |
| lazygit | `~/.config/lazygit/config.yml` |
| starship | `~/.config/starship.toml` |
| git | `~/.config/git/config` |

## Safe Customization Patterns

### Edit User Config Directly

For simple changes, edit files in `~/.config/`:

```bash
# 1. Read current config
cat ~/.config/hypr/bindings.lua

# 2. Backup before changes
cp ~/.config/hypr/bindings.lua ~/.config/hypr/bindings.lua.bak.$(date +%s)

# 3. Make changes with Edit tool

# 4. Apply changes
# - Hyprland: auto-reloads on save, but MUST validate with `hyprctl reload` and `hyprctl configerrors`
# - codeswotOS shell: shell.json and user plugin code under ~/.config/codeswot/plugins/ hot-reload on save
# - Menus/launcher: ~/.config/codeswot/extensions/codeswot-menu.jsonc hot-reloads on save
# - Terminals: apply with `codeswot restart terminal` (reloads running terminals; foot picks changes up in new windows)
```

### Reset to Defaults -- ALWAYS SEEK USER CONFIRMATION BEFORE RUNNING

When customizations go wrong:

```bash
# Reset specific config (creates backup automatically)
codeswot refresh shell
codeswot refresh hyprland

# The refresh command:
# 1. Backs up current config with timestamp
# 2. Copies default from $CODESWOT_PATH/config/
# 3. Restarts the component where the refresh needs it (e.g. `refresh shell`)
```

## System Commands

```bash
codeswot update                  # Full system update
codeswot version                 # Show codeswotOS version
codeswot debug --no-sudo --print # Debug info (ALWAYS use these flags)
codeswot system lock             # Lock screen
codeswot system shutdown         # Shutdown
codeswot system reboot           # Reboot
```

**IMPORTANT:** Always run `codeswot debug` with `--no-sudo --print` flags to avoid interactive sudo prompts that will hang the terminal.

## Troubleshooting

```bash
# Get debug information (ALWAYS use these flags to avoid interactive prompts)
codeswot debug --no-sudo --print

# Reset specific config to defaults
codeswot refresh <app>

# Refresh specific config file
# config-file path is relative to ~/.config/
# eg. `codeswot refresh config hypr/hyprland.lua` will refresh ~/.config/hypr/hyprland.lua
codeswot refresh config <config-file>

# Full reinstall of configs (nuclear option)
codeswot reinstall
```

## Decision Framework

When user requests system changes:

1. **Is it a stock codeswot command?** Use it directly
2. **Is it a config edit?** Edit in `~/.config/`, never `/usr/share/codeswot/`
3. **Is it a theme customization?** Follow [`theming.md`](theming.md); create a NEW custom theme directory
4. **Is it automation?** Follow [`hooks.md`](hooks.md); use `codeswot hook install` and the hook `.d` directories
5. **Is it a package install?** Use `codeswot pkg add <pkgs...>` (or `codeswot pkg aur add <pkgs...>` for AUR-only packages)
6. **Is it built-in shell/plugin code?** Follow [`plugins.md`](plugins.md); clone it with `codeswot plugin clone`, never edit the packaged copy
7. **Unsure if command exists?** Run `codeswot commands` (or `codeswot <group> --help` for one group)

### Reminder Requests

When the user asks to set a reminder, use `codeswot reminder <minutes> [message]` directly. Convert natural language durations to minutes and title-case short reminder labels when appropriate.

```bash
codeswot reminder 15 "Pickup Jack"
codeswot reminder 60 "Check laundry"
codeswot reminder show
codeswot reminder clear
```

## Out of Scope

This skill intentionally does not cover codeswotOS source development. Do not use this skill for:
- Editing files in `/usr/share/codeswot/` (`bin/`, `config/`, `default/`, `shell/`, `themes/`, `migrations/`, etc.)
- Creating or editing migrations
- Running `codeswot dev ...` commands

## Example Requests

- "Change my theme to catppuccin" -> `codeswot theme set catppuccin`
- "Add a keybinding for Super+E to open file manager" -> Check existing bindings first, call `hl.unbind` if needed, then `o.bind` in `~/.config/hypr/bindings.lua`
- "Configure my external monitor" -> Edit `~/.config/hypr/monitors.lua`
- "Make the window gaps smaller" -> Edit `~/.config/hypr/looknfeel.lua`
- "Turn on night light" -> `codeswot toggle nightlight` (for time-based schedules, edit `~/.config/hypr/hyprsunset.conf` profiles, then `codeswot restart hyprsunset`)
- "Set a reminder to pickup jack in 15 minutes" -> `codeswot reminder 15 "Pickup Jack"`
- "Show my reminders" -> `codeswot reminder show`
- "Clear all reminders" -> `codeswot reminder clear`
- "Customize the catppuccin theme colors" -> Overlay: put an edited `colors.toml` in `~/.config/codeswot/themes/catppuccin/`, then re-apply the theme (see `theming.md`)
- "Run a script every time I change themes" -> Install it with `codeswot hook install theme-set <script>`
- "Change how workspace labels are rendered" -> Clone `omarchy.workspaces`, which switches the bar to `<username>.workspaces`, then edit the clone
- "Lock after ten minutes" -> Set `idle.lock` to `600` in `~/.config/codeswot/shell.json`
- "Reset shell/bar to defaults" -> `codeswot refresh shell`
- "Record my screen" -> `codeswot screenrecord --fullscreen`, then `codeswot screenrecord --stop-recording` (see `capture.md`)
- "Report this bug to codeswotOS" -> Gather diagnostics and a capture of the problem, then file it (see `contributing.md`)
