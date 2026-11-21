# Upgrades must not delete the version a running process is executing from:
# mise up would prune the old install dir out from under a live session.
mise settings set upgrade.auto_prune false

codeswot-mise-install codex
codeswot-mise-install claude
codeswot-mise-install crush
codeswot-mise-install gemini
codeswot-mise-install gh
codeswot-mise-install copilot
codeswot-mise-install opencode
codeswot-mise-install npm:playwright playwright
codeswot-mise-install pi
codeswot-mise-install github:can1357/oh-my-pi omp
codeswot-mise-install npm:@xai-official/grok grok
# Cursor's own installer links the same path, so a re-provision keeps it.
codeswot-cmd-missing cursor-agent && codeswot-mise-install cursor-agent
codeswot-mise-install npm:@kitlangton/ghui ghui
codeswot-mise-install aqua:modem-dev/hunk hunk
if codeswot-cmd-missing muse; then
  codeswot-mise-install "http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]" muse
fi
