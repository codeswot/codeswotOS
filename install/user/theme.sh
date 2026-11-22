# Setup user theme folder and seed the default only when no theme exists yet.
mkdir -p ~/.config/codeswot/themes

if [[ ! -s $HOME/.local/state/codeswot/current/theme.name ]]; then
  # iso-chroot and provision-owner both run without a live session to notify.
  if [[ ${CODESWOT_SETUP_CONTEXT:-runtime} != "runtime" ]]; then
    CODESWOT_THEME_HEADLESS=1 codeswot-theme-set "Codeswot"
    rm -f ~/.config/chromium/SingletonLock # otherwise archiso owns the Chromium singleton
  else
    codeswot-theme-set "Codeswot"
  fi
fi
codeswot-theme-set-pi --activate

mkdir -p ~/.config/btop/themes
ln -snf "$HOME/.local/state/codeswot/current/theme/btop.theme" ~/.config/btop/themes/current.theme
