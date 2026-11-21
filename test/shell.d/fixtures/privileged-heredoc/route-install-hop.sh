tmp=$(mktemp)

cat >"$tmp" <<EOF
#!/bin/bash
exec "$HOME/.local/share/codeswot/bin/codeswot-agent" "$@"
EOF

sudo install -m 0755 "$tmp" /usr/local/bin/codeswot-agent-shim
