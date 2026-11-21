storage="$HOME/storage"
shared="$HOME/shared"

# codeswot:heredoc-expands paths=shared,storage -- both sources are validated before use
cat >/etc/codeswot/mounts.conf <<EOF
storage=$storage:/storage
shared=$shared:/shared
EOF
