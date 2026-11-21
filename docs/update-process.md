# codeswotOS update process

This document describes the intended update behavior now that codeswotOS is
package-backed. It covers the blessed update path plus what happens when a user attempts to
bypass it:

1. `codeswot update` — the blessed interactive codeswotOS update flow.
2. `sudo pacman -Syu` — guarded by codeswotOS and aborted with instructions unless
   the user explicitly bypasses the guard.

The design goal is:

- `codeswot update` owns the visible update pipeline: package transaction,
  migrations, post-update hooks, update-state refresh, and restart checks.
- Migrations run per-user after pacman finishes, because they may need `$HOME`,
  DBus/session state, a graphical session, sudo, or user interaction.
- Users who bypass `codeswot update` are nudged back by the pacman guard; if they
  explicitly bypass it, their session is notified when migrations are pending.

## State and coordination files

| Path | Owner | Purpose |
| --- | --- | --- |
| `${XDG_RUNTIME_DIR:-/tmp}/codeswot-update.lock` | user | Prevent overlapping update runs. Owned by `codeswot-update-lock`; compatibility wrappers inherit/respect it. |
| `/tmp/codeswot-update.log` | user | Transcript of `codeswot update`, used by `codeswot-update-analyze-logs`. |
| `~/.local/state/codeswot/current/` | user | Generated active theme, selected theme name, and current background symlink. |
| `~/.local/state/codeswot/migrations/` | user | Per-user migration markers. |
| `~/.local/state/codeswot/reboot-required` | user | Optional reboot marker checked by `codeswot-update-restart`. |
| `~/.local/state/codeswot/restart-*-required` | user | Optional service/app restart markers checked by `codeswot-update-restart`. The shell needs no marker: it is restarted unconditionally after every update. |

## Migration layout

See [`migrations.md`](migrations.md) for the full migration model, authoring
guidelines, and troubleshooting notes.

Migrations live in:

```text
migrations/*.sh
```

They run as the current user through:

```bash
codeswot-migrate
```

Completion state is per-user:

```text
~/.local/state/codeswot/migrations/<migration filename>
```

Every user gets a chance to run every migration. Migrations run as the user;
privileged work should invoke the appropriate helper or privilege prompt.
Migrations must be idempotent; if one user already applied a machine-wide repair,
the migration should no-op for other users.

For watchers and diagnostics, `codeswot-migrate --pending` prints pending
migration names and exits `0` when any are pending. When no migrations are
pending, it prints nothing and exits non-zero.

## Raw pacman guard

The `codeswot` package installs an ALPM pre-transaction hook alongside its guard
binary:

```text
/usr/share/libalpm/hooks/00-codeswot-update-guard.hook
/usr/bin/codeswot-update-pacman-guard
```

It triggers on package upgrades and runs:

```bash
codeswot-update-pacman-guard
```

The guard detects direct pacman system-upgrade commands like `pacman -Syu` or
`pacman --sync --refresh --sysupgrade`. If the upgrade was not launched by an
codeswotOS update command, the hook exits non-zero with `AbortOnFail`, which stops
the transaction before packages are changed.

`codeswot-update-system-pkgs`, `codeswot-refresh-pacman`, `codeswot-reinstall-pkgs`,
and the v4 upgrader run pacman through:

```bash
env CODESWOT_UPDATE_PACMAN=1 pacman ...
```

so the guard allows codeswotOS-owned update flows. A user can intentionally bypass
the guard with:

```bash
sudo env CODESWOT_ALLOW_DIRECT_PACMAN=1 pacman -Syu
```

The guard does not start `codeswot update` itself because pacman is already in a
transaction setup path; it only aborts with instructions.

The `codeswot` package also installs ALPM hooks for `codeswot-settings` /
`codeswot-settings-dev` installs and upgrades. The pre-transaction hook runs
`codeswot-hyprland-reload-guard pause` to disable live Hyprland config reloads
while `/usr/share/codeswot/default/hypr/**` is replaced. The post-transaction
hook runs `codeswot-hyprland-reload-guard resume`, forces one `hyprctl reload`,
and restores the session's previous `misc.disable_autoreload` and
`debug.suppress_errors` values.

## Path 1: `codeswot update`

High-level flow:

```text
codeswot-update
  ├─ ensure transcript logging through script(1) → /tmp/codeswot-update.log
  ├─ codeswot-update-lock
  │    └─ acquire the update lock and run codeswot-update inside it
  ├─ codeswot-update-requires-free-space
  │    └─ check free space on / and warn below the configured threshold
  ├─ confirm unless -y
  ├─ create snapper snapshot, if snapper is installed
  ├─ codeswot-update-stay-awake start
  ├─ run package updates, migrations, hooks, and log analysis
  ├─ codeswot-update-status
  │    └─ refresh or clear the shell update indicator
  ├─ codeswot-update-stay-awake stop
  │    └─ release the sleep inhibitor and restore shell idle state, if changed
  └─ codeswot-update-restart
```

Important behavior:

- In dev-link mode, `codeswot update` fast-forwards the active checkout from its
  configured upstream before changing system packages or running migrations.
- The free-space requirement uses a 10 GiB threshold and stops the update before
  confirmation when it is not met. If free space cannot be determined, the
  check is silently skipped. Set `CODESWOT_UPDATE_FORCE=1` to bypass the check.
- `codeswot update` checks/runs migrations in the same visible terminal via
  `codeswot-migrate` after pacman finishes.
- A failure should leave enough output in `/tmp/codeswot-update.log` and the
  terminal transcript to debug.

## Path 2: direct `sudo pacman -Syu` attempt

High-level flow:

```text
sudo pacman -Syu
  ├─ pre-transaction guard aborts and tells the user to run codeswot update
  └─ if explicitly bypassed, upgrades codeswot and related packages
  └─ at that user's next login
       ├─ graphical-session.target starts
       ├─ codeswot-migrate-notify.service starts after it
       ├─ codeswot-migrate-notify checks codeswot-migrate --pending
       ├─ if this user has missing migration state, show notification
       └─ click opens terminal: codeswot-migrate
```

Login is deliberately the only trigger. A watcher on the packaged migration
directory cannot distinguish a bypassed `pacman -Syu` from the package
transaction inside a normal `codeswot update`, so it fired notifications for
migrations that `codeswot-migrate` was about to apply in the visible update
terminal. The retired unit was `codeswot-update-user-notify.path`.

Retiring that watcher through a migration cannot come in time for the update
that retires it: pacman writes the migration directory, the watcher fires, and
only then does `codeswot-migrate` reach the migration that stops it. So the
notifier also refuses to run while `codeswot update` holds its
`$XDG_RUNTIME_DIR/codeswot-update.lock`, which covers the stale watcher and any
trigger added later — during an update, every pending migration is by
definition already being applied a step away. It checks again after waiting for
the notification server, since that wait is long enough for an update to start
underneath it.

The notifier reads only its own user's runtime directory, never the `/tmp` path
`codeswot-update` falls back to when `XDG_RUNTIME_DIR` is unset. A shared lock
file belongs to whoever created it first, so honouring it would let one user
silence another user's notification. Missing an update and showing a redundant
toast is the better failure.

Suppression is why `codeswot-update-stay-awake` starts its sleep inhibitor with
the lock descriptor closed. That inhibitor outlives the step that starts it, so
an update killed before cleanup would otherwise leave it holding the flock
indefinitely — blocking later updates and, now that the notifier reads the same
lock, silencing migration notifications at every login.

Fallbacks:

- `codeswot-provision-first-run` enables `codeswot-migrate-notify.service`, which also
  covers users created after install: their per-user migration markers are
  missing, so their first login prompts them to run every shipped migration.
- The package ships `codeswot-update-user-notify.service` as a symlink onto
  `codeswot-migrate-notify.service`. Users set up before the rename hold an
  absolute `graphical-session.target.wants` symlink to the old path, and the
  migration that repoints it only runs for users who run an update — the
  opposite of who the notifier is for. The alias can be dropped once installs
  have run migration `1785095882`.
- The notifier is ordered after `graphical-session.target`, so an action that
  launches through `uwsm-app` cannot block the target that gates UWSM's app
  daemon.
- The notifier waits for a live notification server before sending, because
  `graphical-session.target` can be reached before the shell claims
  `org.freedesktop.Notifications`.
- The notifier is only a prompt. It does not run migrations in the background.
- A session that is already open when another user updates is not re-checked;
  it picks the migrations up at its next login, or whenever that user runs
  `codeswot-migrate` or `codeswot update`.
- Direct pacman updates do not run `codeswot-hook post-update` unless the user
  explicitly runs that hook; without a package-update marker, the only pending
  state we can derive is missing per-user migration markers.

## Shell update indicator

The bar widget `omarchy.system-update` runs:

```bash
codeswot-update-available
```

`codeswot-update-available` checks the active codeswotOS sources for updates:

- new upstream commits for the active dev-linked checkout
- `codeswot-dev`, when installed
- otherwise `codeswot`, when installed

The dev check fetches the checkout's configured upstream before comparing it
with `HEAD`. A failed fetch is quiet and falls back to the existing remote-
tracking state.

Exit codes:

- `0` — codeswotOS updates are available; stdout is the update list.
- non-zero — no codeswotOS updates are available; stdout says codeswotOS is up to date.

The widget runs this check on shell startup and every six hours. Clicking the
update icon launches `codeswot-update` in a floating terminal.

## Update-related binaries

This inventory is intentionally opinionated. Some commands are useful as stable
leaf commands; others exist mostly because the old update flow accreted small
scripts.

| Binary | Current purpose | Keep? / Question |
| --- | --- | --- |
| `codeswot-update` | Public user command. Adds transcript logging, confirmation, snapshot, and restart checks around the locked, sleep-inhibited update pipeline. | **Keep.** This is the blessed entry point and orchestrates the update pipeline. |
| `codeswot-update-lock` | Hidden command wrapper that holds the per-user update lock while its child runs. | **Keep internal/hidden.** Isolates update concurrency and lock descriptor handling. |
| `codeswot-update-stay-awake` | Hidden helper that starts or stops update-owned sleep and idle inhibition, restoring only the state it changed. | **Keep internal/hidden.** Keeps inhibitor ownership and cleanup together. |
| `codeswot-update-status` | Hidden helper that refreshes or clears the shell update indicator after rechecking available updates. | **Keep internal/hidden.** Keeps shell status synchronization out of the main pipeline. |
| `codeswot-update-confirm` | Gum confirmation copy for `codeswot update`. | **Question.** Could be inlined into `codeswot-update`; separate file only helps keep copy isolated. |
| `codeswot-update-dev` | Fast-forwards the active dev-linked checkout from its configured upstream; no-ops for package-backed installs. | **Keep.** Runs before package updates so a checkout conflict stops the update before system mutation. |
| `codeswot-update-keyring` | Ensures codeswotOS keyring and Arch keyring are current before the main transaction. | **Keep, but review.** It uses targeted `pacman -Sy` for keyring bootstrapping; acceptable for this special case but should remain tightly scoped. |
| `codeswot-update-system-pkgs` | Runs `sudo env CODESWOT_UPDATE_PACMAN=1 pacman -Syu --noconfirm` with targeted transition `--overwrite` entries so the ALPM guard allows the transaction and early package-layout conflicts are handled. | **Keep for now.** Small leaf command, clear/testable. |
| `codeswot-migrate` | Public migration command. Waits for pacman, then runs all pending migrations for the current user. Supports `--pending`. | **Keep.** This replaces the discarded `codeswot-update-user-finalize` name and no longer needs `--force`. |
| `codeswot-update-pacman-guard` | ALPM pre-transaction guard that aborts direct `pacman -Syu` style upgrades unless codeswotOS set `CODESWOT_UPDATE_PACMAN=1` or the user explicitly set `CODESWOT_ALLOW_DIRECT_PACMAN=1`. | **Keep internal/hidden.** This is what nudges users back to `codeswot update`. |
| `codeswot-migrate-notify` | Internal login-time notification helper. Uses `codeswot-migrate --pending` and shows a notification only when this user has pending migrations. | **Keep internal/hidden.** Clear name now that the public command is `codeswot-migrate`. |
| `codeswot-update-user-notify` | Hidden compatibility wrapper for `codeswot-migrate-notify`. | **Temporary.** Keep only for old callers. |
| `codeswot-update-available` | Update checker for shell widget and post-update refresh. | **Keep.** Could eventually be renamed `codeswot-update-check`, but current name matches widget semantics. |
| `codeswot-update-aur-pkgs` | Updates AUR packages with `yay -Sua` if foreign packages exist and AUR is reachable. | **Question.** codeswotOS is package-backed now, but users may still install AUR packages. Keep for now. |
| `codeswot-update-mise` | Runs `mise up` for mise-managed tools. | **Keep.** Mise-managed tools are intentionally part of the blessed update path. |
| `codeswot-update-orphan-pkgs` | Lists orphans and prompts before removal; noninteractive mode never removes. | **Keep for now.** Safe because it is prompt-only. |
| `codeswot-update-analyze-logs` | Scans `/tmp/codeswot-update.log` for known failure patterns, currently initramfs generation. | **Keep/expand.** Useful safety net; should grow only for high-signal checks. |
| `codeswot-update-restart` | Prompts for reboot after kernel/Hyprland updates, restarts components with `restart-*-required` markers, and always restarts the shell. | **Keep.** Important final step; may eventually include service-restart checks. |
| `codeswot-update-firmware` | Manual firmware update command using fwupd. Not part of the normal update pipeline. | **Keep separate.** Firmware is not a routine system update step. |
| `codeswot-update-time` | Restarts `systemd-timesyncd`. | **Question.** Not really an update command. Consider renaming/moving under system/time maintenance. |

## Closed decisions

1. **Migrations run per-user from the update pipeline**
   - `codeswot update` runs `codeswot-migrate` after pacman finishes.
   - Package-time migration runners do not apply migrations inside pacman.
   - Every user has per-user migration markers, and migrations must be
     idempotent when they repair machine-wide state.

2. **Migration notification naming**
   - The real helper is `codeswot-migrate-notify`, started by
     `codeswot-migrate-notify.service`.
   - `codeswot-update-user-notify` remains only as a hidden compatibility wrapper.

3. **Update pipeline ownership**
   - `codeswot-update` owns the full update pipeline now.

4. **Mise remains in the blessed update path**
   - `codeswot-update-mise` intentionally runs as part of `codeswot update`.

5. **Orphan cleanup stays in the update path for now**
   - It is prompt-only and never removes packages noninteractively.

6. **Direct pacman user follow-up is based on actual migration state**
   - Direct `sudo pacman -Syu` no longer uses a fake user-update marker.
   - User notifications are shown only when `codeswot-migrate --pending` finds
     missing per-user migration state.

## Remaining concerns

1. **Pacman guard scope**
   - The guard detects direct pacman sysupgrade invocations and allows codeswotOS
     commands that set `CODESWOT_UPDATE_PACMAN=1`.
   - We may regret blocking some legitimate package-manager frontends or
     maintenance flows. Keep an eye on what should be allowed versus redirected
     to `codeswot update`.

2. **Pacnew/pacsave handling is still missing**
   - Package-backed codeswotOS should warn about or help process `.pacnew` and
     `.pacsave` files after updates.
