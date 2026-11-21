# Capture and Sharing

Read this before taking screenshots or screen recordings, extracting text from
the screen, or sharing files with other machines.

## Screenshots

```bash
codeswot screenshot                            # Interactive smart-region flow
codeswot capture screenshot region             # Select a region
codeswot capture screenshot windows            # Pick a window
codeswot capture screenshot fullscreen save    # Full screen, straight to disk (no editor)
```

The first argument picks the mode (`smart|region|windows|fullscreen`), the
second what happens with it (`slurp|copy|save`). `save` skips the annotation
editor and prints the saved path. Screenshots land in the configured Pictures
directory (override with `CODESWOT_SCREENSHOT_DIR`).

## Screen Recording

```bash
codeswot screenrecord --fullscreen             # Start recording the full screen
# ...exercise whatever you want on film...
codeswot screenrecord --stop-recording         # Stop; prints the saved path
```

Optional flags: `--with-desktop-audio`, `--with-microphone-audio`,
`--with-webcam` (plus `--webcam-device=` and `--webcam-size=`), and
`--resolution=<size>`. Without `--fullscreen` a region picker opens first.
Recordings land in the configured Videos directory (override with
`CODESWOT_SCREENRECORD_DIR`). Resize a live webcam overlay with
`codeswot capture webcam resize <smaller|larger|reset|small|medium|large>`.

If recording fails to start, rerun with `CODESWOT_SCREENRECORD_DEBUG=true` to
collect a log at `/tmp/codeswot-screenrecord.log` worth attaching to a bug
report.

## Text Capture (OCR)

```bash
codeswot capture text    # Select a region; extracted text goes to the clipboard
```

## Sharing Files

```bash
codeswot share clipboard               # Share the clipboard via LocalSend
codeswot share file <path...>          # Share files with nearby devices
codeswot share folder <path>           # Share a folder

codeswot tailscale send <machine> <file...>    # Taildrop to a tailnet machine
codeswot tailscale receive [directory]         # Save incoming Taildrop files
```

Shrink large captures before sharing them:

```bash
codeswot transcode <input> [format] [resolution]   # Re-encode pictures/videos for sharing
```
