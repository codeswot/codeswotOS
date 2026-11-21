# `>|` is a plain redirect with noclobber overridden, not a redirect into a pipe.
cat >|/etc/codeswot/agent.conf <<EOF
helper=$HOME/.local/share/codeswot/bin/codeswot-agent
EOF
