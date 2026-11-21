#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log_file="$test_tmp/channel.log"
mkdir -p "$stub_bin" "$test_tmp/home"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<<"$body"
  chmod +x "$stub_bin/$name"
}

write_stub codeswot-refresh-pacman '#!/bin/bash
printf "refresh" >>"$CODESWOT_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$CODESWOT_CHANNEL_TEST_LOG"; done
printf "\n" >>"$CODESWOT_CHANNEL_TEST_LOG"
'

write_stub sudo '#!/bin/bash
printf "sudo" >>"$CODESWOT_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$CODESWOT_CHANNEL_TEST_LOG"; done
printf "\n" >>"$CODESWOT_CHANNEL_TEST_LOG"
'

write_stub codeswot-dev-unlink '#!/bin/bash
printf "unlink" >>"$CODESWOT_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$CODESWOT_CHANNEL_TEST_LOG"; done
printf "\n" >>"$CODESWOT_CHANNEL_TEST_LOG"
'

write_stub codeswot-state '#!/bin/bash
printf "state" >>"$CODESWOT_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$CODESWOT_CHANNEL_TEST_LOG"; done
printf "\n" >>"$CODESWOT_CHANNEL_TEST_LOG"
'

write_stub codeswot-update '#!/bin/bash
printf "update" >>"$CODESWOT_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$CODESWOT_CHANNEL_TEST_LOG"; done
printf "\tCODESWOT_PATH=%s" "$CODESWOT_PATH" >>"$CODESWOT_CHANNEL_TEST_LOG"
printf "\n" >>"$CODESWOT_CHANNEL_TEST_LOG"
'

write_stub gum '#!/bin/bash
printf "gum" >>"$CODESWOT_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$CODESWOT_CHANNEL_TEST_LOG"; done
printf "\n" >>"$CODESWOT_CHANNEL_TEST_LOG"
exit 0
'

write_stub git '#!/bin/bash
printf "git" >>"$CODESWOT_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$CODESWOT_CHANNEL_TEST_LOG"; done
printf "\n" >>"$CODESWOT_CHANNEL_TEST_LOG"
if [[ $1 == "clone" ]]; then
  dest="${@: -1}"
  mkdir -p "$dest/.git" "$dest/bin" "$dest/default" "$dest/shell"
fi
'

write_stub codeswot-dev-link '#!/bin/bash
printf "link" >>"$CODESWOT_CHANNEL_TEST_LOG"
for arg in "$@"; do printf "\t%s" "$arg" >>"$CODESWOT_CHANNEL_TEST_LOG"; done
printf "\n" >>"$CODESWOT_CHANNEL_TEST_LOG"
'

write_stub codeswot-version-channel '#!/bin/bash
printf "%s\n" "${CODESWOT_TEST_VERSION_CHANNEL:-unknown}"
'

write_stub pacman '#!/bin/bash
[[ $1 == "-Q" ]] || exit 1
shift
case "${CODESWOT_TEST_PACKAGES:-}" in
  stable) [[ $* == "codeswot codeswot-settings" ]] ;;
  dev) [[ $* == "codeswot-dev codeswot-settings-dev" ]] ;;
  *) exit 1 ;;
esac
'

run_channel() {
  : >"$log_file"
  CODESWOT_CHANNEL_TEST_LOG="$log_file" \
    CODESWOT_PATH="${CODESWOT_TEST_PATH:-/usr/share/codeswot}" \
    HOME="$test_tmp/home" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/codeswot-channel-set" "$@"
}

assert_log_line() {
  local expected="$1"
  local description="$2"

  grep -Fx -- "$expected" "$log_file" >/dev/null || fail "$description" "$(cat "$log_file")"
  pass "$description"
}

run_channel stable
assert_log_line $'refresh\tstable' "stable refreshes the stable pacman channel"
assert_log_line $'sudo\tenv\tCODESWOT_UPDATE_PACMAN=1\tpacman\t-S\t--needed\t--noconfirm\t--ask\t4\tcodeswot\tcodeswot-settings' "stable installs stable codeswotOS packages"
assert_log_line $'unlink\t--no-reboot' "stable restores the package-backed codeswotOS path without an early reboot prompt"
assert_log_line $'update\t-y\tCODESWOT_PATH=/usr/share/codeswot' "stable runs the normal update pipeline from the package-backed path"
if grep -q $'^state\tset\treboot-required$' "$log_file"; then
  fail "stable does not require reboot when already package-backed" "$(cat "$log_file")"
fi
pass "stable does not require reboot when already package-backed"

run_channel rc
assert_log_line $'refresh\trc' "rc refreshes the rc pacman channel"
assert_log_line $'sudo\tenv\tCODESWOT_UPDATE_PACMAN=1\tpacman\t-S\t--needed\t--noconfirm\t--ask\t4\tcodeswot\tcodeswot-settings' "rc installs rc codeswotOS packages"
assert_log_line $'unlink\t--no-reboot' "rc restores the package-backed codeswotOS path without an early reboot prompt"
assert_log_line $'update\t-y\tCODESWOT_PATH=/usr/share/codeswot' "rc runs the normal update pipeline from the package-backed path"

CODESWOT_TEST_PATH="$ROOT" run_channel edge
assert_log_line $'refresh\tedge' "edge refreshes the edge pacman channel"
assert_log_line $'sudo\tenv\tCODESWOT_UPDATE_PACMAN=1\tpacman\t-S\t--needed\t--noconfirm\t--ask\t4\tcodeswot-dev\tcodeswot-settings-dev' "edge installs development codeswotOS packages"
assert_log_line $'unlink\t--no-reboot' "edge unlinks dev without an early reboot prompt"
assert_log_line $'state\tset\treboot-required' "edge marks reboot required when leaving dev"
assert_log_line $'update\t-y\tCODESWOT_PATH=/usr/share/codeswot' "edge runs the normal update pipeline from the package-backed path"
[[ $(grep -E '^(unlink|state|update)' "$log_file") == $'unlink\t--no-reboot\nstate\tset\treboot-required\nupdate\t-y\tCODESWOT_PATH=/usr/share/codeswot' ]] ||
  fail "edge defers the reboot prompt until the update restart stage" "$(cat "$log_file")"
pass "edge defers the reboot prompt until the update restart stage"

checkout="$test_tmp/home/codeswot"
mkdir -p "$checkout"
if run_channel dev >"$test_tmp/occupied.out" 2>"$test_tmp/occupied.err"; then
  fail "dev refuses to use an occupied non-checkout path"
fi

grep -q "already exists and is not a git checkout" "$test_tmp/occupied.err" || fail "dev explains occupied checkout paths" "$(cat "$test_tmp/occupied.err")"
if grep -Fx $'refresh\tedge' "$log_file" >/dev/null; then
  fail "dev validates checkout path before changing packages" "$(cat "$log_file")"
fi
pass "dev refuses occupied non-checkout paths before package changes"

rmdir "$checkout"
run_channel dev
assert_log_line $'gum\tconfirm\t--default=false\tSwitch to dev channel?' "dev asks for confirmation"
assert_log_line $'refresh\tedge' "dev refreshes the edge pacman channel"
assert_log_line $'sudo\tenv\tCODESWOT_UPDATE_PACMAN=1\tpacman\t-S\t--needed\t--noconfirm\t--ask\t4\tcodeswot-dev\tcodeswot-settings-dev' "dev installs development codeswotOS packages"
assert_log_line $'git\tclone\thttps://github.com/omacom/omarchy.git\t'"$checkout" "dev clones the source checkout to ~/codeswot"
assert_log_line $'link\t'"$checkout"$'\t--no-reboot' "dev links ~/codeswot without an early reboot prompt"
assert_log_line $'state\tset\treboot-required' "dev defers the reboot prompt to the update pipeline"
assert_log_line $'update\t-y\tCODESWOT_PATH='"$checkout" "dev runs the normal update pipeline from the source checkout"
[[ $(grep -E '^(git|link|state|refresh|sudo|update)' "$log_file") == $'git\tclone\thttps://github.com/omacom/omarchy.git\t'"$checkout"$'\nlink\t'"$checkout"$'\t--no-reboot\nstate\tset\treboot-required\nrefresh\tedge\nsudo\tenv\tCODESWOT_UPDATE_PACMAN=1\tpacman\t-S\t--needed\t--noconfirm\t--ask\t4\tcodeswot-dev\tcodeswot-settings-dev\nupdate\t-y\tCODESWOT_PATH='"$checkout" ]] ||
  fail "dev activates the checkout before changing or updating packages" "$(cat "$log_file")"
pass "dev activates the checkout before changing or updating packages"

CODESWOT_TEST_PATH="$checkout" run_channel stable
assert_log_line $'unlink\t--no-reboot' "switching from dev to stable unlinks without an early reboot prompt"
assert_log_line $'state\tset\treboot-required' "switching from dev to stable marks reboot required"

run_channel dev
if grep -q $'^git\tclone\t' "$log_file"; then
  fail "dev reuses an existing checkout" "$(cat "$log_file")"
fi
assert_log_line $'link\t'"$checkout"$'\t--no-reboot' "switching back to dev links ~/codeswot"
pass "switching back to dev reuses the existing ~/codeswot checkout"

current_channel() {
  CODESWOT_TEST_VERSION_CHANNEL="$1" \
    CODESWOT_TEST_PACKAGES="$2" \
    CODESWOT_PATH="$3" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/codeswot-channel-current"
}

[[ $(current_channel stable stable /usr/share/codeswot) == "stable" ]] || fail "current channel detects stable"
pass "current channel detects stable"

[[ $(current_channel rc stable /usr/share/codeswot) == "rc" ]] || fail "current channel detects rc"
pass "current channel detects rc"

[[ $(current_channel edge dev /usr/share/codeswot) == "edge" ]] || fail "current channel detects package-backed edge"
pass "current channel detects package-backed edge"

[[ $(current_channel edge dev "$test_tmp/dev-checkout") == "dev" ]] || fail "current channel detects dev from CODESWOT_PATH"
pass "current channel honors a dev link outside ~/codeswot"
