#!/bin/sh
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BASE="$HOME/.local/share/TrunGameFreeMega"
APP="$BASE/App"
LOG="$BASE/DataSense/build-linux.log"
SUCCESS=0
ERROR_REASON='Installation stopped unexpectedly. See Read More for details.'
mkdir -p "$BASE/DataSense"
: > "$LOG"
report() { printf '%s\n' "$*" | tee -a "$LOG"; }
finish() {
  ret=$?
  trap - EXIT
  if [ "$SUCCESS" -eq 1 ] && [ "$ret" -eq 0 ]; then
    report '[BUILD SUCCESS] Installer verified catalog and created a launcher inside the project folder.'
    state=success
    message='The native Linux app launcher is inside this project folder. No Desktop shortcut was created.'
  else
    report "[BUILD FATAL ERROR] $ERROR_REASON (exit $ret)"
    state=fatal
    message="$ERROR_REASON"
  fi
  if [ "${TRUN_INSTALL_NONINTERACTIVE:-0}" != 1 ] && [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && command -v wish >/dev/null 2>&1; then
    wish "$HERE/linux/BuildStatus.tcl" "$state" "$message" "$LOG" || :
  fi
  exit "$ret"
}
trap 'finish' EXIT
if ! command -v wish >/dev/null 2>&1; then
  ERROR_REASON='Tcl/Tk (wish) is required. Ubuntu/Debian: sudo apt install tk.'
  exit 1
fi
for file in catalog.tsv credits.txt catalog-original.txt assets/MEGA-Logo.png assets/MEGA-Logo.ico linux/TrunGameFreeMega.tcl linux/'Start Linux.sh' linux/BuildStatus.tcl; do
  if [ ! -f "$HERE/$file" ]; then ERROR_REASON="Required file missing: $file"; exit 1; fi
done
count=$(($(wc -l < "$HERE/catalog.tsv") - 1))
if [ "$count" -ne 40 ]; then ERROR_REASON="Unexpected catalog size: $count (expected 40)."; exit 1; fi
mkdir -p "$APP/assets" "$APP/linux" "$HOME/.local/share/applications"
cp "$HERE/catalog.tsv" "$HERE/credits.txt" "$HERE/catalog-original.txt" "$APP/"
cp "$HERE/assets/MEGA-Logo.png" "$HERE/assets/MEGA-Logo.ico" "$APP/assets/"
cp "$HERE/linux/TrunGameFreeMega.tcl" "$HERE/linux/Start Linux.sh" "$APP/linux/"
chmod +x "$APP/linux/Start Linux.sh"
# Launcher references the installed app; moving the downloaded folder won't break it.
RUN="$APP/linux/Start Linux.sh"
execpath=$(printf '%s' "$RUN" | sed 's/\\/\\\\/g; s/"/\\"/g; s/%/%%/g')
ENTRY="$HERE/Trun Game Free Mega.desktop"
cat > "$ENTRY" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=Trun Game Free Mega
Comment=Native desktop game-link directory
Exec=/bin/sh "$execpath"
Icon=$APP/assets/MEGA-Logo.png
Terminal=false
Categories=Game;Utility;
StartupNotify=true
EOF
chmod +x "$ENTRY"
# Also register in the applications menu, never on the Desktop.
cp "$ENTRY" "$HOME/.local/share/applications/trun-game-free-mega.desktop"
chmod +x "$HOME/.local/share/applications/trun-game-free-mega.desktop"
# Remove only a previous shortcut belonging to this project.
for desk in "$HOME/Desktop" "$HOME/Área de Trabalho"; do
  old="$desk/Trun Game Free Mega.desktop"
  if [ -f "$old" ] && grep -q 'TrunGameFreeMega/App/linux/Start Linux.sh' "$old"; then
    rm -f "$old"
    report '[CLEANUP] Removed old project desktop launcher.'
  fi
done
if command -v gio >/dev/null 2>&1; then
  gio set "$ENTRY" metadata::trusted true >/dev/null 2>&1 || :
fi
if [ ! -f "$ENTRY" ] || [ ! -f "$APP/catalog.tsv" ]; then
  ERROR_REASON='Launcher or installed catalog verification failed.'; exit 1
fi
# GNOME file managers use .hidden to conceal support files. Other file managers differ.
cat > "$HERE/.hidden" <<'HIDDEN'
.github
Installer Windows.bat
Installer Linux.sh
Installer macOS.command
Repair Windows.bat
Repair Linux.sh
Repair macOS.command
assets
linux
macos
windows
catalog.tsv
catalog-original.txt
credits.txt
PREVIEW-LINUX.png
README-EN.txt
README-PTBR.txt
TEST-RESULTS.txt
HIDDEN
report '[FILES] Installed native application in user data directory.'
report "[SHORTCUT] Launcher created inside project folder: $ENTRY"
report '[DATA] Previous history preserved.'
SUCCESS=1
