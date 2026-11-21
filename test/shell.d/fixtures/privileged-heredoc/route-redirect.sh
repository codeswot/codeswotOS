# A plain redirect into /etc, no sudo: the command re-execs itself as root.
cat >/etc/codeswot/agent.conf <<EOF
helper=$HOME/.local/share/codeswot/bin/codeswot-agent
EOF
