mkdir -p ~/.config/codeswot

cat >~/.config/codeswot/agent.conf <<EOF
helper=$HOME/.local/share/codeswot/bin/codeswot-agent
EOF

cat >"$HOME/.local/bin/codeswot-shim" <<EOF
exec "$CODESWOT_PATH/bin/codeswot-agent" "$@"
EOF
