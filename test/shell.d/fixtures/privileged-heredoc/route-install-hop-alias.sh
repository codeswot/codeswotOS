tmp=/tmp/codeswot-generated
copy=$tmp
cat >"$tmp" <<EOF
command=$HOME/.local/share/codeswot/bin/example
EOF
sudo install -m644 "$copy" /etc/codeswot/example.conf
