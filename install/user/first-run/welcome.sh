# Real newlines, not a literal \n: the card renders the body as it arrives, and
# elides past three lines.
codeswot-notification-send -u critical -g  "Learn Keybindings" \
  $'Super + K for cheatsheet.\nSuper + Space for codeswotOS Menu.' \
  --exec codeswot-menu-keybindings
