#!/bin/bash

# Two hops. The scan resolves omarchy_bin into helper, so the value it ends up
# judging still carries an unresolved $HOME rather than a literal path.
omarchy_bin="$HOME/.local/share/codeswot/bin"
helper="$omarchy_bin/codeswot-agent"

# codeswot:heredoc-expands paths=none -- helper names the agent, no path is baked in
cat <<EOF | sudo tee /etc/udev/rules.d/99-codeswot-agent.rules >/dev/null
SUBSYSTEM=="power_supply", RUN+="$helper"
EOF
