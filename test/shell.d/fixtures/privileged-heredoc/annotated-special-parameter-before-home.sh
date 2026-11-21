# codeswot:heredoc-expands paths=none -- the positional argument is a scalar
sudo tee /etc/codeswot/example.conf <<EOF
argument=$1
command=$HOME/.local/share/codeswot/bin/example
EOF
