tmp=/tmp/codeswot-generated
cat >"$tmp" <<EOF
command=$HOME/.local/share/codeswot/bin/example
EOF
sudo install -m644 "${tmp}" /etc/codeswot/example.conf
