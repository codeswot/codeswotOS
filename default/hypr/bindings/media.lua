-- Volume, brightness, keyboard backlight, and touchpad controls.
o.bind("XF86AudioRaiseVolume", "Volume up", "codeswot-audio-output-volume raise", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "codeswot-audio-output-volume lower", { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", "codeswot-audio-output-volume mute-toggle", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "codeswot-audio-input-mute", { locked = true })
o.bind("XF86MonBrightnessUp", "Brightness up", "codeswot-brightness-display +5%", { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", "codeswot-brightness-display 5%-", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessUp", "Brightness maximum", "codeswot-brightness-display 100%", { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessDown", "Brightness minimum", "codeswot-brightness-display 1%", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessUp", "Keyboard brightness up", "codeswot-brightness-keyboard up", { locked = true, repeating = true })
o.bind("XF86KbdBrightnessDown", "Keyboard brightness down", "codeswot-brightness-keyboard down", { locked = true, repeating = true })
o.bind("XF86KbdLightOnOff", "Keyboard backlight cycle", "codeswot-brightness-keyboard cycle", { locked = true })
o.bind_toggle("XF86TouchpadToggle", "Toggle touchpad", "touchpad", { locked = true })
o.bind("XF86TouchpadOn", "Enable touchpad", "codeswot-toggle-touchpad on", { locked = true })
o.bind("XF86TouchpadOff", "Disable touchpad", "codeswot-toggle-touchpad off", { locked = true })

-- Precise volume and brightness controls.
o.bind("ALT + XF86AudioRaiseVolume", "Volume up precise", "codeswot-audio-output-volume +1", { locked = true, repeating = true })
o.bind("ALT + XF86AudioLowerVolume", "Volume down precise", "codeswot-audio-output-volume -1", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessUp", "Brightness up precise", "codeswot-brightness-display +1%", { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessDown", "Brightness down precise", "codeswot-brightness-display 1%-", { locked = true, repeating = true })

-- Media controls.
o.bind("XF86AudioNext", "Next track", "codeswot-shell media next", { locked = true })
o.bind("ALT + XF86AudioPlay", "Next track", "codeswot-shell media next", { locked = true })
o.bind("XF86AudioPause", "Pause", "codeswot-shell media playPause", { locked = true })
o.bind("XF86AudioPlay", "Play", "codeswot-shell media playPause", { locked = true })
o.bind("XF86AudioPrev", "Previous track", "codeswot-shell media previous", { locked = true })
o.bind("ALT + SHIFT + XF86AudioPlay", "Previous track", "codeswot-shell media previous", { locked = true })
o.bind("XF86Eject", "Eject media", "eject", { locked = true })

o.bind("SHIFT + XF86AudioMute", "Switch audio output", "codeswot-audio-output-switch", { locked = true })
o.bind("SHIFT + XF86AudioPause", "Switch media source", "codeswot-audio-source-switch", { locked = true })
o.bind("SHIFT + XF86AudioPlay", "Switch media source", "codeswot-audio-source-switch", { locked = true })
