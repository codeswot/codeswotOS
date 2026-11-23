#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

home="$tmp/home"
stub="$tmp/stub"
units="$tmp/units"
mkdir -p "$home/.config/omarchy/plugins/codeswot.menu" "$home/.config/omarchy/themes/codeswot" \
  "$home/.config/omarchy/hooks/post-update.d" "$home/.config/hypr" \
  "$home/.config/systemd/user/graphical-session.target.wants" \
  "$home/.local/state/omarchy/migrations" "$stub" "$units"

cat >"$home/.config/hypr/hyprland.lua" <<'LUA'
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")
require("default.hypr.omarchy")
o.bind("SUPER + RETURN", "Terminal", { omarchy = "terminal" })
LUA
printf -- '-- macOS Style Keybindings Configuration\nhl.unbind("SUPER + W")\n' >"$home/.config/hypr/bindings.lua"
cat >"$home/.config/omarchy/shell.json" <<'JSON'
{
  "bar": {
    "layout": {
      "left": [{"id": "codeswot.menu"}, {"id": "omarchy.workspaces"}],
      "center": [{"id": "omarchy.clock"}, {"id": "omarchy.menu"}],
      "right": [{"id": "omarchy.tray"}]
    }
  },
  "plugins": [{"id": "codeswot.lock"}, {"id": "third.widget"}],
  "disabledPlugins": ["omarchy.menu", "omarchy.lock", "omarchy.notifications"],
  "cloneSourceRestores": ["codeswot.menu", "codeswot.lock"]
}
JSON
echo 'omarchy-hook-ran' >"$home/.config/omarchy/hooks/post-update.d/restore-plymouth.hook"
echo 'exec omarchy-voxtype-install' >"$home/.config/omarchy/hooks/post-update.d/install-voxtype.hook"
touch "$home/.local/state/omarchy/migrations/1700000000.sh"
ln -s /usr/lib/systemd/user/omarchy-sleep-lock.service \
  "$home/.config/systemd/user/graphical-session.target.wants/omarchy-sleep-lock.service"
ln -s /usr/lib/systemd/user/omarchy-gone.service \
  "$home/.config/systemd/user/graphical-session.target.wants/omarchy-gone.service"
touch "$units/codeswot-sleep-lock.service"

for command in systemctl codeswot-migrate; do
  printf '#!/bin/bash\necho "${0##*/} $*" >>"%s/calls"\n' "$tmp" >"$stub/$command"
  chmod +x "$stub/$command"
done

adopt() {
  HOME="$home" CODESWOT_PATH="$ROOT" CODESWOT_USER_UNIT_DIR="$units" PATH="$stub:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/codeswot-adopt-omarchy" "$@"
}

adopt --dry-run >/dev/null 2>&1 || fail "dry run succeeds"
[[ -d $home/.config/omarchy && ! -L $home/.config/omarchy && ! -e $home/.config/codeswot ]] ||
  fail "dry run leaves the Omarchy directories alone"
pass "dry run changes nothing"

adopt >/dev/null 2>&1 || fail "adoption succeeds"

[[ -L $home/.config/omarchy && $(readlink "$home/.config/omarchy") == codeswot ]] ||
  fail "~/.config/omarchy becomes a link to ~/.config/codeswot"
[[ -f $home/.local/state/codeswot/migrations/1700000000.sh ]] ||
  fail "migration markers move with the state directory"
pass "Omarchy directories move and leave links behind"

grep -Fq 'require("default.hypr.codeswot")' "$home/.config/hypr/hyprland.lua" &&
  grep -Fq 'os.getenv("CODESWOT_PATH") or "/usr/share/codeswot"' "$home/.config/hypr/hyprland.lua" &&
  grep -Fq '{ codeswot = "terminal" }' "$home/.config/hypr/hyprland.lua" ||
  fail "hyprland.lua loads the codeswotOS defaults" "$(cat "$home/.config/hypr/hyprland.lua")"
grep -Fq 'codeswot-voxtype-install' "$home/.config/codeswot/hooks/post-update.d/install-voxtype.hook" ||
  fail "installed hooks call codeswot commands"
pass "personal configs are rewritten"

layout=$(jq -c '[.bar.layout.left[].id, .bar.layout.center[].id]' "$home/.config/codeswot/shell.json")
[[ $layout == '["omarchy.menu","omarchy.workspaces","omarchy.clock"]' ]] ||
  fail "the cloned menu becomes the built-in one, without a duplicate" "$layout"
[[ $(jq -c '[.plugins[].id, .disabledPlugins, .cloneSourceRestores]' "$home/.config/codeswot/shell.json") == '["third.widget",["omarchy.notifications"],null]' ]] ||
  fail "clone bookkeeping is dropped and other choices are kept" "$(cat "$home/.config/codeswot/shell.json")"
[[ ! -e $home/.config/codeswot/plugins/codeswot.menu && ! -e $home/.config/codeswot/themes/codeswot ]] ||
  fail "cloned plugins and the personal codeswot theme are retired"
[[ ! -e $home/.config/codeswot/hooks/post-update.d/restore-plymouth.hook ]] ||
  fail "branding guard hooks are retired"
cmp -s "$ROOT/config/hypr/bindings.lua" "$home/.config/hypr/bindings.lua" ||
  fail "personal macOS keybindings give way to the default ones"
pass "customizations that are now defaults are retired"

[[ ! -e $home/.config/systemd/user/graphical-session.target.wants/omarchy-sleep-lock.service ]] ||
  fail "old service links are removed"
grep -Fxq 'systemctl --user enable codeswot-sleep-lock.service' "$tmp/calls" ||
  fail "services are re-enabled under their codeswot names" "$(cat "$tmp/calls")"
! grep -q 'codeswot-gone' "$tmp/calls" || fail "services codeswotOS lacks are not enabled"
grep -Fxq 'codeswot-migrate ' "$tmp/calls" || fail "pending migrations run"
pass "user services move to their codeswot names and migrations run"

ls "$home/.local/share/codeswot"/adopt-backup-*.tar.gz >/dev/null 2>&1 ||
  fail "a backup is written before anything changes"
tar -tzf "$home"/.local/share/codeswot/adopt-backup-*.tar.gz | grep -q '^.config/omarchy/shell.json$' ||
  fail "the backup holds the original Omarchy config"
pass "the original setup is backed up"

calls_before=$(wc -l <"$tmp/calls")
adopt >/dev/null 2>&1 || fail "a second run succeeds"
(( $(wc -l <"$tmp/calls") == calls_before )) || fail "a second run changes nothing"
pass "adoption runs once"
