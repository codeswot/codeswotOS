#!/bin/bash

cat <<EOF | \
  sudo tee /etc/codeswot/review.conf
ExecStart=$HOME/.local/bin/payload
EOF
