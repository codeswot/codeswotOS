sudo dd status=none of=/etc/codeswot/boot.conf <<EOF
cmdline=$boot_params
EOF
