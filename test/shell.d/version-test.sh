#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# The edge channel installs codeswot-dev. Older builds did not declare
# provides=(codeswot), so a query for plain codeswot finds nothing there.
cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
[[ $1 == "-Q" ]] || exit 1
shift
for package in "$@"; do
  case ",${CODESWOT_TEST_PACKAGES:-}," in
    *",$package,"*)
      echo "$package ${CODESWOT_TEST_VERSION:-4.0.0-1}"
      exit 0
      ;;
  esac
done
echo "error: package '$1' was not found" >&2
exit 1
STUB
chmod +x "$stub_bin/pacman"

version() {
  CODESWOT_TEST_PACKAGES="$1" \
    CODESWOT_PATH="${2:-/usr/share/codeswot}" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/codeswot-version"
}

[[ $(version codeswot) == "4.0.0-1" ]] || fail "version reports the stable package"
pass "version reports the stable package"

[[ $(version codeswot-dev) == "4.0.0-1" ]] || fail "version reports the edge package"
pass "version reports the edge package"

# A checkout reports its hash instead, so packages are irrelevant there.
[[ $(version "" "$test_tmp/checkout") == "dev" ]] || fail "version reports a dev checkout"
pass "version reports a dev checkout"

if version "" >/dev/null 2>&1; then
  fail "version fails when no codeswotOS package is installed"
fi
pass "version fails when no codeswotOS package is installed"

# The snapshot description is only a label, so a failed lookup must not abort
# the update under set -e.
snapshot_desc=$(
  set -e
  PATH="$stub_bin:$PATH" CODESWOT_TEST_PACKAGES="" CODESWOT_PATH=/usr/share/codeswot \
    bash -c 'DESC="$(codeswot-version 2>/dev/null || echo unknown)"; echo "$DESC"' 2>/dev/null
) || fail "snapshot survives an unknown version"

[[ $snapshot_desc == "unknown" ]] || fail "snapshot labels an unknown version" "actual: $snapshot_desc"
pass "snapshot survives an unknown version"
