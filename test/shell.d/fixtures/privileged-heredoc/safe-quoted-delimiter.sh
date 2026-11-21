cat <<'EOF' | sudo tee /etc/udev/rules.d/99-omarchy.rules >/dev/null
SUBSYSTEM=="power_supply", RUN+="/usr/bin/codeswot-powerprofiles-set $HOME"
EOF

cat <<"XML" | sudo tee /etc/codeswot/agent.xml >/dev/null
<config path="$HOME/.local/share/codeswot" />
XML
