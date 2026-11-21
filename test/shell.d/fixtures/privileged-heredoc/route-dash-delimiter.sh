if true; then
  cat <<-EOF | sudo tee /etc/codeswot/indented.conf >/dev/null
	helper=$HOME/.local/share/codeswot/bin/codeswot-agent
	EOF
fi
