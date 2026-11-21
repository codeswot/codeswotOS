echo "Install the Dell XPS 13 Panther Lake speaker firmware"

if codeswot-hw-dell-xps13-dx13260-ptl; then
  source "$CODESWOT_PATH/install/hardware/dell-xps13-ptl-speaker-firmware.sh"
  codeswot-state set reboot-required
fi
