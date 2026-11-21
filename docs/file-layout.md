# File layout

How `codeswot/` is organized and where everything ends up on an installed
system.

## Mental model

Two Arch packages are built from this one repo (PKGBUILDs live in
`codeswot-pkgs/pkgbuilds/`):

- **`codeswot`** — runtime binaries (`bin/`, including `bin/codeswot-dev-*`),
  install/finalize scripts (`install/`), migrations, themes, and the
  Quickshell desktop (`shell/`). Depends on `codeswot-settings`.
- **`codeswot-settings`** — everything that has to be on the target *before*
  the codeswot package installs (specifically before `useradd -m` and the
  limine bootloader install): all `/etc/skel/**`, `/etc/` drop-ins,
  package-owned system files under `/usr/share` and `/usr/lib`, fonts,
  plymouth theme, sddm theme, branding, plus the limine/snapper configs
  (mkinitcpio hooks, limine-entry-tool drop-ins, snapper template, the
  `default/limine/` and `default/snapper/` trees, and the boot/snapshot
  story end-to-end). Also ships the three debug binaries
  (`codeswot-debug`, `codeswot-debug-idle`, `codeswot-upload-log`) needed by
  the live ISO env.

Two other packages live in `codeswot-pkgs/` but stand alone:
`omarchy-keyring` (GPG keys for pacman) and `omarchy-nvim` (the Neovim
setup; independently seeds `/etc/skel`).

Three layers populate `$HOME`:

1. **Seed** — `codeswot-settings` ships static defaults to `/etc/skel/`.
   Arch's `useradd -m` copies that tree into a new user's `$HOME` at user
   creation. This is the only mechanism that touches a brand-new user's home
   for these files.
2. **Finalize** — `codeswot-finalize-user` runs once per user and handles the
   things `/etc/skel` can't do because they need `$HOME` expansion, the live
   `$CODESWOT_PATH`, or runtime detection of system state.
3. **Resync** — `codeswot-reinstall-configs` is the explicit, destructive
   command for an existing user to clobber their configs back to shipped
   defaults.

`/etc/skel` only fires at user creation. Existing users picking up new
defaults must use the resync command.

Current generated theme state lives under
`~/.local/state/codeswot/current/`. Keep `~/.config/codeswot/` for files a user
may intentionally version in a dotfile manager, such as user themes, hooks,
shell layout, plugins, and themed template overrides.

## Build-time map (repo → installed paths)

```
codeswot/                            built into          installed at
─────────────────────────           ──────────────      ────────────────────────────────────

bin/codeswot-*                  ──►  codeswot             /usr/bin/codeswot-*
                                                        (and symlinks in /usr/share/codeswot/bin/)
bin/codeswot-debug,
bin/codeswot-debug-idle,
bin/codeswot-upload-log         ──►  codeswot-settings    /usr/bin/  (needed before codeswot is installed)

default/libalpm/hooks/*.hook
                                ──►  codeswot             /usr/share/libalpm/hooks/*.hook

install/**                     ──►  codeswot             /usr/share/codeswot/install/
migrations/**                  ──►  codeswot             /usr/share/codeswot/migrations/
themes/**                      ──►  codeswot             /usr/share/codeswot/themes/
shell/**                       ──►  codeswot             /usr/share/codeswot/shell/
version                        ──►  codeswot             /usr/share/codeswot/version
                                                        + /etc/skel/.local/state/codeswot/migrations/*

config/**                      ──►  codeswot-settings    /etc/skel/.config/**         (seeds new users)
                                                        /usr/share/codeswot/config/** (resync source)
etc/fastfetch/config.jsonc     ──►  codeswot-settings    /etc/fastfetch/config.jsonc
etc/xdg/kitty/kitty.conf       ──►  codeswot-settings    /etc/xdg/kitty/kitty.conf

applications/*.desktop         ──►  codeswot-settings    /etc/skel/.local/share/applications/
                                                        /usr/share/codeswot/applications/
default/applications/battlenet.desktop
                                ──►  codeswot-settings    /usr/share/codeswot/default/applications/
                                                        (installer-only launcher template)
applications/icons/*           ──►  codeswot-settings    /usr/share/icons/hicolor/{48,256,scalable}/apps/

etc/**                         ──►  codeswot-settings    /etc/**           (drop-ins we own outright)
  ├─ mkinitcpio.conf.d/{omarchy_hooks,thunderbolt_module}.conf
  └─ limine-entry-tool.d/{codeswot-defaults,codeswot-uki}.conf

default/limine/limine.conf     ──►  codeswot-settings    /usr/share/codeswot/default/limine/limine.conf
default/limine/default.conf    ──►  codeswot-settings    /usr/share/codeswot/default/limine/default.conf
                                                        (template; ISO substitutes @@CMDLINE@@ → /etc/default/limine)
default/snapper/root           ──►  codeswot-settings    /etc/snapper/config-templates/codeswot
                                                        (+ /usr/share/codeswot/default/snapper/root)

default/**                     ──►  codeswot-settings    /usr/share/codeswot/default/
  ├─ bash/env-bootstrap                                 /usr/share/codeswot/default/bash/env-bootstrap
  │                                                       (sourced by every shell/session entry point; see "Env bootstrap")
  ├─ bashrc                                             /usr/share/codeswot/etc-overrides/dot.bashrc
  │                                                       → /etc/skel/.bashrc (post_install cp -f)
  ├─ hypr/toggles/flags.lua                             /etc/skel/.local/state/codeswot/toggles/hypr/
  ├─ nautilus-python/extensions/*.py                    /etc/skel/.local/share/nautilus-python/extensions/
  ├─ tensaku/state.toml                                 /etc/skel/.local/state/tensaku/state.toml
  ├─ uwsm/env.d/10-codeswot                              /usr/share/uwsm/env.d/
  ├─ environment.d/*.conf                               /usr/lib/environment.d/
  ├─ fontconfig/conf.avail/50-codeswot.conf              /usr/share/fontconfig/conf.avail/
  │                                                       + symlink /etc/fonts/conf.d/50-codeswot.conf
  ├─ xdg-terminal-exec/*.list                           /usr/share/xdg-terminal-exec/
  ├─ applications/mimeapps.list                         /usr/share/applications/mimeapps.list
  ├─ systemd/user/*.{service,path}                      /usr/lib/systemd/user/
  ├─ systemd/user/app.slice.d/10-oomd.conf              /usr/lib/systemd/user/app.slice.d/
  ├─ systemd/system-sleep/unmount-fuse                  /usr/lib/systemd/system-sleep/
  ├─ systemd/zram-generator.conf.d/90-codeswot.conf      /usr/lib/systemd/zram-generator.conf.d/
  ├─ fonts/omarchy/omarchy.ttf                          /usr/share/fonts/omarchy/
  ├─ sddm/codeswot/                                      /usr/share/sddm/themes/codeswot/
  ├─ sddm/hyprland.lua                                  /usr/share/sddm/hyprland.lua
  ├─ wayland-sessions/codeswot.desktop                   /usr/local/share/wayland-sessions/
  ├─ plymouth/                                          /usr/share/plymouth/themes/codeswot/
  └─ security/faillock, nsswitch, cups-browsed,
     plymouthd.conf, os-release                         /usr/share/codeswot/etc-overrides/
                                                          → /etc/* (post_install cp -f, see below)

logo.{txt,svg}, icon.{txt,png}  ──► codeswot-settings    /usr/share/codeswot/  (resync source)
                                                        /usr/share/pixmaps/codeswot.png
                                                        /usr/share/icons/hicolor/256x256/apps/codeswot.png
                                                        /etc/skel/.config/codeswot/branding/{about,screensaver}.txt
```

The hardware-conditional `force-igpu` and `keyboard-backlight` sources also live under `default/systemd/system-sleep/`, but their setup commands publish root-owned copies only on machines that need them; they are not installed by `codeswot-settings`.

### Why `etc-overrides/` exists

Some files under `/etc/` (`.bashrc` in `/etc/skel`, `nsswitch.conf`,
`security/faillock.conf`, `cups/cups-browsed.conf`, `plymouth/plymouthd.conf`,
`os-release`) are owned by upstream Arch packages, so we can't install over
them via pacman without a file conflict. Instead they ship at
`/usr/share/codeswot/etc-overrides/` and the `codeswot-settings` `post_install`
/ `post_upgrade` scriptlet `cp -f`'s them into place.

Tradeoff: user edits to those files get clobbered on every `codeswot-settings`
upgrade. This is documented in the PKGBUILD.

## Locate indexing

`default/systemd/system/plocate-updatedb.service.d/10-codeswot.conf` ships through `codeswot-settings` to `/usr/lib/systemd/system/plocate-updatedb.service.d/10-codeswot.conf`. It replaces the existing service's `ExecStart` with `updatedb --prune-bind-mounts=no --add-prunepaths=/.snapshots`, keeping Btrfs subvolume mounts searchable and excluding Snapper snapshots. The upstream service retains its timer, resource limits, and sandbox; codeswotOS's existing AC-power condition still applies.

`/etc/updatedb.conf` remains owned by plocate and is never rewritten by codeswotOS. The command-line options override bind-mount pruning and add to the administrator's existing path exclusions. Installer and AUR package refreshes pass the same options directly because installation may run without systemd and an explicitly requested refresh should work on battery.

Arch's systemd package hook reloads units when the vendor drop-in is installed or upgraded. The settings package containing the drop-in must ship alongside the runtime package that removes the old configuration helper and migration. Pacman removes those retired files; no new state migration is needed. A running indexer finishes with its original options, and subsequent service starts use the drop-in. For an immediate local test after installing the packages, restart `plocate-updatedb.service` while connected to AC power.

## Env bootstrap (`default/bash/env-bootstrap`)

Single source of truth for `CODESWOT_PATH` and dev-link-aware `PATH`. It:

- Sources `/etc/codeswot.conf` (written by `codeswot-dev-link`, reset to the
  package path by `codeswot-dev-unlink`) if present; otherwise forces
  `CODESWOT_PATH=/usr/share/codeswot` so a stale inherited value can't survive
  an `codeswot-dev-unlink`.
- Prepends `$CODESWOT_PATH/bin` to `PATH` **only when** `CODESWOT_PATH` is
  not `/usr/share/codeswot`. On a production install the binaries are
  already on `PATH` as `/usr/bin/codeswot-*` via the `codeswot` package.

Sourced by every entry point that needs the env set:

```
/etc/profile.d/codeswot.sh                      (system login shells)
/etc/skel/.bashrc                              (interactive shells)
/usr/share/uwsm/env.d/10-codeswot               (Hyprland session via uwsm)
/usr/share/codeswot/default/bash/envs           (SSH / non-login bash)
```

Idempotent — safe to source more than once in the same shell.

`PATH` covers everything the user runs, but not `sudo`, which resolves command
names against `secure_path` from `/etc/sudoers`. So `codeswot-dev-link` also
writes `/etc/sudoers.d/codeswot-dev-path`:

```
Defaults secure_path="<checkout>/bin:/usr/local/sbin:/usr/local/bin:/usr/bin"
```

Without it, `sudo codeswot-*` fails for a command the package has not shipped
yet and silently runs the packaged copy of one it has. The drop-in is validated
with `visudo -c` before install and removed by `codeswot-dev-unlink`; unlike
`/etc/codeswot.conf`, it takes effect without a reboot.

## Runtime finalization (`codeswot-finalize-user`)

Runs once per user. It does **not** copy `~/.config/**`, `~/.bashrc`,
`flags.lua`, or the nautilus extensions — `/etc/skel` already seeded those.
It only does the things `/etc/skel` can't:

- Skill symlinks into `~/.agents/skills/<name>`, `~/.claude/skills/<name>`, `~/.codex/skills/<name>`, `~/.pi/agent/skills/<name>`, `~/.hermes/skills/<name>`, and each existing `~/.hermes/profiles/*/skills/<name>` → `$CODESWOT_PATH/default/agents/skills/<name>`, looping over every skill directory there (currently `codeswot` and `diagnose-crash`) so new skills need no edit. Symlinks (not copies) so `codeswot dev link` against a dev checkout repoints them correctly. Hermes profile dirs are only linked when they already exist — provision does not create Hermes profiles.
- `xdg-user-dirs-update` (Templates/Public/Desktop folded back into `$HOME`)
  and `~/.config/gtk-3.0/bookmarks` (needs `$HOME` expansion).
- Hyprland's package-owned default input reads `XKBLAYOUT` / `XKBVARIANT`
  from `/etc/vconsole.conf`; no per-user Hyprland config rewrite is needed.
- `xdg-settings set default-web-browser chromium.desktop` and
  `xdg-mime default HEY.desktop x-scheme-handler/mailto` (XDG-aware paths).
- `codeswot-refresh-applications` (composes generated `.desktop` launchers).
- Sources `install/user/all.sh` — theme, git, mise, keyring, per-user
  hardware quirks (asus mic/mixer, framework f13 audio, …).
- On `--first-install`, marks every shipped user migration as already applied
  for the freshly-created user.

Idempotency marker: `~/.local/state/codeswot/done/finalize-user`, managed
by `codeswot-done`.

The ISO calls it as `codeswot-finalize-user --force --first-install` in the
target chroot as the install user, after `codeswot-apply-system` has finished
the root-side work.

## Migrations (`codeswot-migrate`)

See [`migrations.md`](migrations.md) for the full migration model, authoring
guidelines, and troubleshooting notes.

codeswotOS migrations live in `migrations/*.sh` and run per-user through
`codeswot-migrate`. Completion state lives in
`~/.local/state/codeswot/migrations/`, so every user gets a chance to run every
migration. Migrations run as the user; privileged work should invoke the
appropriate helper or privilege prompt. Migrations must be idempotent;
machine-wide repairs should no-op when another user already applied them.

Each graphical user has `codeswot-migrate-notify.service`, started once per login
through `WantedBy=graphical-session.target` and ordered after that target so
notification actions can safely launch through UWSM. The package also ships
`codeswot-update-user-notify.service` as a symlink onto it, so users enabled
under the old unit name keep working before they reach migration `1785095882`.
It runs `codeswot-migrate-notify` as
that user, which checks `codeswot-migrate --pending`. If this user has missing
migration state, it shows a notification that opens a terminal for
`codeswot-migrate`. The notifier never runs migrations in the background.

Login is the only trigger. Nothing watches the packaged migration directory: a
watcher cannot tell a bypassed `pacman -Syu` from the package transaction inside
a normal `codeswot update`, so it notified about migrations that `codeswot-migrate`
was already applying in the visible update terminal.

`codeswot-migrate` waits for any active pacman transaction to finish, then runs
pending migrations. It does not need `--force`; migrations happen when state
files are missing. `codeswot update` runs `codeswot-migrate` after the package
transaction in the already-visible update terminal, then runs
`codeswot-hook post-update`.

## First-run (`codeswot-provision-first-run`)

Runs once on first interactive login, after the user manager is live. Used
for steps that need a running graphical session and/or a working user
systemd instance:

- `codeswot-hook-install post-update install-voxtype.hook` — register the
  Voxtype post-update hook.
- `install/user/first-run/enable-user-units.sh` — `systemctl --user enable`
  the shipped user units (`bt-agent`, `codeswot-sleep-lock`,
  `codeswot-recover-internal-monitor`, `codeswot-migrate-notify.service`,
  `codeswot-fcitx5.service`).
  Done here, not at finalize, because
  the user manager isn't reachable from the ISO chroot; `ConditionPath*`
  in the unit files keeps services inert when they don't apply.
- `install/user/first-run/gnome-theme.sh`,
  `install/user/first-run/gtk-primary-paste.sh` — GNOME/GTK settings that
  need the dconf daemon.
- `install/user/first-run/welcome.sh` — keybindings toast that greets the
  first login and opens the cheatsheet when clicked.
- `install/user/first-run/wifi.sh` — Wi-Fi/update toasts (waits for a live
  notification server before firing, then waits detached on `nm-online` so the
  update prompt only lands once there is a connection).

The entire sequence has one idempotency marker:
`~/.local/state/codeswot/done/first-run-user`, managed by `codeswot-done`.
Completed users exit before any first-run step. On failure the marker is not
written and the sequence retries next login.

Completion markers live under `~/.local/state/codeswot/done/`. Use
`codeswot-done check <name>` to check one and `codeswot-done mark <name>` to record it.
Use `codeswot-done ensure <name>` as a conditional when the guarded work should
run only once; it records completion before returning success.
The Quattro upgrade completes graphical first-run for upgraded users and moves
the legacy finalization marker from `~/.local/state/codeswot/` into `done/`.

## Root-side install orchestration

`codeswot-apply-system` (root, in chroot) runs target-side setup at ISO
finalization. It sources:

- `install/config/all.sh` — theme links, lockout limits, lockscreen PAM,
  powerprofilesctl shebang fix, docker setup, Snapper retention, locate
  index tuning, service enablement, firewall.
- `install/hardware/all.sh` via `codeswot-apply-hardware` — vendor- and
  device-specific kernel modules, udev rules, microcode, wireless regdom,
  ASUS / Framework / Intel / Apple / Lenovo quirks.
- `install/login/all.sh` — SDDM theme/session config.
- `install/post-install/all.sh` — final pacman/udev/localdb passes.

Logging goes to `/var/log/codeswot-install.log` via
`install/helpers/logging.sh`.

## Explicit resync (`codeswot-reinstall-configs`)

When an existing user wants to reset to shipped defaults:

```
~/  ←  cp -af /etc/skel/.
```

Replaying `/etc/skel` over `$HOME` is exactly what `useradd -m` does for a
brand-new user, so this one copy resyncs `.bashrc`, `.config/**`,
`.local/share/applications/`, the nautilus-python extensions, hypr toggles,
branding files, and the shipped migration markers in a single pass.

Then it runs `codeswot-refresh-limine`, `codeswot-refresh-plymouth`, and the
nvim refresh. Destructive: existing user files copied from `/etc/skel` are
clobbered without backup. Fastfetch is package-owned at
`/etc/fastfetch/config.jsonc`; delete `~/.config/fastfetch/config.jsonc` to
return to the packaged default.

## Quick reference: where does X live?

| Goal | Touch |
| --- | --- |
| Default file at `~/.config/foo/` | `config/foo/` |
| `/etc/` drop-in we own outright | `etc/` |
| `/etc/` file owned by an upstream package | `default/`, then add to `etc-overrides` in `codeswot-settings` PKGBUILD + scriptlet |
| Package-owned system file (e.g. systemd user service/path in `/usr/lib`) | `default/`, document the mapping in `default/package-defaults.tsv`, then add the `install -Dm644` line in `codeswot-settings` PKGBUILD |
| Per-user file that's static but lives outside `~/.config` | `default/`, then add `install -Dm644 ... $pkgdir/etc/skel/...` in `codeswot-settings` PKGBUILD |
| Runtime tweak that needs `$HOME` or live system state | extend `codeswot-finalize-user`, or add a per-user leaf under `install/user/` and wire into `install/user/all.sh` |
| One-time root-side setup step | `install/config/*.sh` or `install/hardware/*.sh`, wire into `install/config/all.sh` or `install/hardware/all.sh` |
| One-time fix for existing installs | `migrations/<unix-timestamp>.sh` |
| Package-owned path something else may already write | Prefer a path nothing else writes, such as a vendor drop-in under `/usr/lib`. Otherwise the `--overwrite` entry in `bin/codeswot-update-system-pkgs` has to ship a release before the file |
| User-facing `codeswot-*` command | `bin/codeswot-<group>-<verb>` — see `GROUP_DESCRIPTIONS` in `bin/codeswot` |
| New stock theme | `themes/<name>/` (+ matching templates under `default/themed/` if they need theme colors) |
| User-installed theme | `~/.config/codeswot/themes/<name>/` |
| Generated current theme/background state | `~/.local/state/codeswot/current/` |

## Kitty defaults and user overrides

Kitty loads `/etc/xdg/kitty/kitty.conf` before `~/.config/kitty/kitty.conf`. The `codeswot-settings` package owns the system file; the user template contains only the active theme include and commented examples for personal overrides. Keeping the theme include in the user file lets users remove it without changing the packaged defaults. Individual inherited keybindings can be unmapped with an empty `map <shortcut>` directive, or all inherited bindings can be cleared with `clear_all_shortcuts yes`.

The system default uses `allow_remote_control socket-only` so codeswotOS can query the active terminal directory over its Unix socket while Kitty rejects remote-control requests arriving through terminal output. Changing this setting requires restarting Kitty. The migration refreshes the exact previous stock config with a backup; customized configs retain their settings and ordering, with only explicit unrestricted `yes`, `y`, or `true` remote-control settings commented out.
