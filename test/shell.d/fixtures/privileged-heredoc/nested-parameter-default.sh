#!/bin/bash

# codeswot:heredoc-expands paths=none -- review regression fixture
sudo tee /etc/codeswot/review.conf >/dev/null <<EOF
ExecStart=${target:-$HOME/.local/bin/payload}
EOF
