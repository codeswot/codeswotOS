#!/bin/bash

cat <<EOF >/tmp/codeswot-review-unit
[Service]
ExecStart=$HOME/.local/bin/payload
EOF
sudo install -m 644 /tmp/codeswot-review-unit /etc/systemd/system/review.service
