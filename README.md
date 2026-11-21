# codeswotOS

codeswotOS is Mubarak Ibrahim's personal Arch Linux distribution: Hyprland,
the Quickshell desktop, and the {C}odeswot look, delivered as pacman packages
with snapshot-protected updates.

It is a hard fork of [Omarchy](https://github.com/basecamp/omarchy) by David
Heinemeier Hansson and contributors, based on Omarchy v4.0.6 (see
[`UPSTREAM`](UPSTREAM)). The original MIT license and copyright are kept in
[`LICENSE`](LICENSE).

## Working on codeswotOS

- `tools/rebrand` converts Omarchy trees and patches to codeswotOS names. Its
  rules, and the reasons some Omarchy names are kept on purpose, are at the
  top of the script.
- `tools/sync-upstream <tag>` brings a newer Omarchy release in as a
  rebranded 3-way merge.
- `./test/all` runs the CLI and shell test suites.

## The codeswotOS Manual

The manual lives in [`manual/`](manual/). It started as the Omarchy manual and
still describes Omarchy behavior in places.

- [Welcome to codeswotOS!](manual/01-welcome-to-codeswot.md)

**The Basics**

- [Getting Started](manual/02-getting-started.md)
- [Coming From Mac or Windows](manual/03-coming-from-mac-or-windows.md)
- [Navigation](manual/04-navigation.md)
- [The top bar](manual/05-the-top-bar.md)
- [Themes](manual/06-themes.md)
- [Hotkeys](manual/07-hotkeys.md)
- [Unified Clipboard & History](manual/08-unified-clipboard-history.md)
- [Reminders](manual/09-reminders.md)
- [Notices](manual/10-notices.md)
- [Text Extraction & Dictation](manual/11-text-extraction-dictation.md)
- [Screenshots & Recording](manual/12-screenshots-recording.md)
- [Toggles, idle & screensaver](manual/13-toggles-idle-screensaver.md)
- [codeswotOS CLI](manual/14-codeswot-cli.md)

**The Applications**

- [Terminal](manual/15-terminal.md)
- [Neovim](manual/16-neovim.md)
- [AI](manual/17-ai.md)
- [Development Tools](manual/18-development-tools.md)
- [Shell Tools](manual/19-shell-tools.md)
- [Shell Functions](manual/20-shell-functions.md)
- [TUIs](manual/21-tuis.md)
- [GUIs](manual/22-guis.md)
- [Browsers](manual/23-browsers.md)
- [Commercial apps/services](manual/24-commercial-apps-services.md)
- [Web Apps](manual/25-web-apps.md)
- [Gaming](manual/26-gaming.md)
- [Filling out PDFs](manual/27-filling-out-pdfs.md)
- [Windows VM](manual/28-windows-vm.md)
- [Other Packages](manual/29-other-packages.md)

**Configuration**

- [Updates](manual/30-updates.md)
- [Dotfiles](manual/31-dotfiles.md)
- [Shell plugins](manual/32-shell-plugins.md)
- [Monitors](manual/33-monitors.md)
- [Keyboard, Mouse, Trackpad](manual/34-keyboard-mouse-trackpad.md)
- [Networking](manual/35-networking.md)
- [System sleep](manual/36-system-sleep.md)
- [Hardware authentication](manual/37-hardware-authentication.md)
- [Fonts](manual/38-fonts.md)
- [Backgrounds](manual/39-backgrounds.md)
- [Prompt](manual/40-prompt.md)
- [Branding](manual/41-branding.md)
- [Common tweaks](manual/42-common-tweaks.md)
- [Making your own theme](manual/43-making-your-own-theme.md)

**The Rest**

- [Mac support](manual/44-mac-support.md)
- [Troubleshooting](manual/45-troubleshooting.md)
- [FAQ](manual/46-faq.md)
- [System snapshots](manual/47-system-snapshots.md)
- [Security](manual/48-security.md)
- [codeswotOS on...](manual/49-codeswot-on.md)
- [Dual Boot Install](manual/50-dual-boot-install.md)
- [Unattended Installs](manual/51-unattended-installs.md)

## License

codeswotOS is released under the [MIT License](LICENSE), the same license as
Omarchy, whose copyright notice it keeps.
