#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home/.config/chromium" "$test_tmp/home/.local/state/codeswot/current"

cat >"$mock_bin/codeswot-theme-set" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CODESWOT_TEST_THEME_CALLS"
SH
chmod +x "$mock_bin/codeswot-theme-set"

for command in codeswot-theme-set-pi; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
exit 0
SH
  chmod +x "$mock_bin/$command"
done

calls="$test_tmp/theme-calls"
touch "$test_tmp/home/.config/chromium/SingletonLock"
HOME="$test_tmp/home" PATH="$mock_bin:$PATH" CODESWOT_TEST_THEME_CALLS="$calls" \
  bash "$ROOT/install/user/theme.sh"
grep -Fx 'Codeswot' "$calls" >/dev/null || fail "user theme setup seeds Codeswot when no theme exists"
[[ -f $test_tmp/home/.config/chromium/SingletonLock ]] || fail "runtime user theme setup preserves Chromium's singleton lock"

: >"$calls"
printf 'Solitude\n' >"$test_tmp/home/.local/state/codeswot/current/theme.name"
HOME="$test_tmp/home" PATH="$mock_bin:$PATH" CODESWOT_TEST_THEME_CALLS="$calls" \
  bash "$ROOT/install/user/theme.sh"
[[ ! -s $calls ]] || fail "user theme setup preserves an existing theme"

pass "user theme setup only seeds the default theme once"
