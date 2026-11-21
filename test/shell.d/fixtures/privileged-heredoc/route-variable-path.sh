DROP_IN=/etc/systemd/system/codeswot-agent.service.d/override.conf

cat <<EOF | sudo tee "$DROP_IN" >/dev/null
[Service]
ExecStart=$CODESWOT_PATH/bin/codeswot-agent
EOF
