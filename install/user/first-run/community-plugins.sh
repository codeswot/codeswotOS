#!/bin/bash

# Install the community shell plugins the default bar uses. They come from
# their own repositories so they stay updatable with `codeswot plugin update`
# and keep their authors' licenses. Runs at first-run because it needs the
# network, which the ISO chroot may not have; a failure retries next login.
#
# config/codeswot/shell.json already places and enables them, and the shell
# skips layout entries for plugins that aren't installed yet.

set -euo pipefail

declare -A plugins=(
  [io.github.iryzhkov.omadeck]="https://github.com/iryzhkov/omarchy-omadeck.git"
  [njpatel.omapager]="https://github.com/njpatel/omapager.git"
)

for id in "${!plugins[@]}"; do
  [[ -d $HOME/.config/codeswot/plugins/$id ]] && continue
  codeswot-plugin-add "${plugins[$id]}" --yes
done
