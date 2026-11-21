echo "Relink Neovim theme to codeswotOS current state"

theme_link="$HOME/.config/nvim/lua/plugins/theme.lua"
legacy_absolute_target="$HOME/.config/codeswot/current/theme/neovim.lua"
legacy_relative_target="../../../codeswot/current/theme/neovim.lua"
legacy_home_target="~/.config/codeswot/current/theme/neovim.lua"
current_relative_target="../../../../.local/state/codeswot/current/theme/neovim.lua"

[[ -L $theme_link ]] || exit 0

target=$(readlink "$theme_link") || exit 0

case "$target" in
  "$legacy_absolute_target"|"$legacy_relative_target"|"$legacy_home_target")
    ln -sfn "$current_relative_target" "$theme_link"
    ;;
esac
