#!/bin/bash
set -euo pipefail
SUCCESS=0
FAILURE_REASON='The installer stopped unexpectedly.'
LOG="$HOME/Library/Application Support/TrunGameFreeMega/DataSense/build-macos.log"
mkdir -p "$(dirname "$LOG")"
: > "$LOG"
report() { printf '%s\n' "$*" | tee -a "$LOG"; }
on_error() { FAILURE_REASON="Failure at line $1 while running: $2"; report "[ERROR] $FAILURE_REASON"; }
finish() {
  code=$?
  trap - ERR EXIT
  if [ "$SUCCESS" -eq 1 ] && [ "$code" -eq 0 ]; then
    mode=success
    message='The native application was built inside this project folder. No Desktop shortcut was created.'
    report '[BUILD SUCCESS] Native SwiftUI application build passed.'
  else
    mode=fatal
    message="$FAILURE_REASON"
    report "[BUILD FATAL ERROR] $message (exit $code)"
    if [ -n "${INSTALL:-}" ] && [ -d "${INSTALL}.previous" ] && [ ! -e "$INSTALL" ]; then
      mv "${INSTALL}.previous" "$INSTALL" || :
    fi
  fi
  if [ "${TRUN_INSTALL_NONINTERACTIVE:-0}" != 1 ] && command -v osascript >/dev/null 2>&1; then
    osascript - "$mode" "$message" "$LOG" <<'APPLESCRIPT' || :
on run argv
  set buildMode to item 1 of argv
  set buildMessage to item 2 of argv
  set buildLog to item 3 of argv
  if buildMode is "success" then
    set titleText to "BUILD SUCCESS"
  else
    set titleText to "BUILD FATAL ERROR"
  end if
  set picked to display dialog buildMessage with title ("Trun Game Free Mega - " & titleText) buttons {"Close", "Read More"} default button "Close"
  if button returned of picked is "Read More" then
    tell application "TextEdit" to open (POSIX file buildLog)
    activate application "TextEdit"
  end if
end run
APPLESCRIPT
  fi
  exit "$code"
}
trap finish EXIT
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR
HERE="$(cd "$(dirname "$0")" && pwd)"
APP_NAME='Trun Game Free Mega.app'
INSTALL="$HERE/$APP_NAME"
SOURCE="$HERE/macos/TrunGameFreeMega.swift"
if [ "$(uname -s)" != 'Darwin' ]; then FAILURE_REASON='This installer must run on macOS.'; report "[ERROR] $FAILURE_REASON"; exit 1; fi
if ! command -v xcrun >/dev/null 2>&1 || ! xcrun --find swiftc >/dev/null 2>&1; then
  FAILURE_REASON='Apple Swift compiler is required for the first build.'
  report "[ERROR] $FAILURE_REASON"
  echo 'Install Apple Command Line Tools by running: xcode-select --install'
  echo 'This step is necessary only for building from source, not for running a prebuilt release.'
  exit 1
fi
for file in catalog.tsv credits.txt assets/MEGA-Logo.png "$SOURCE"; do
  if [ ! -f "$HERE/$file" ] && [ ! -f "$file" ]; then FAILURE_REASON="Required file missing: $file"; report "[ERROR] $FAILURE_REASON"; exit 1; fi
done
TEMP="$(mktemp -d "${TMPDIR:-/tmp}/trunmega.XXXXXXXX")"
trap 'rm -rf "$TEMP"' EXIT
BUILT="$TEMP/$APP_NAME"
mkdir -p "$BUILT/Contents/MacOS" "$BUILT/Contents/Resources"
cat > "$BUILT/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundleExecutable</key><string>TrunGameFreeMega</string>
<key>CFBundleIdentifier</key><string>com.trunmega.freegame</string>
<key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
<key>CFBundleName</key><string>Trun Game Free Mega</string>
<key>CFBundleDisplayName</key><string>Trun Game Free Mega</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>2.2</string>
<key>CFBundleVersion</key><string>220</string>
<key>LSMinimumSystemVersion</key><string>11.0</string>
<key>NSHighResolutionCapable</key><true/>
<key>CFBundleIconFile</key><string>MEGA-Logo</string>
</dict></plist>
PLIST
cp "$HERE/catalog.tsv" "$HERE/credits.txt" "$HERE/assets/MEGA-Logo.png" "$BUILT/Contents/Resources/"
SDK="$(xcrun --sdk macosx --show-sdk-path)"
xcrun swiftc -O -parse-as-library -sdk "$SDK" -framework AppKit -framework SwiftUI \
  "$SOURCE" -o "$BUILT/Contents/MacOS/TrunGameFreeMega"
chmod +x "$BUILT/Contents/MacOS/TrunGameFreeMega"
ICONSET="$TEMP/MEGA-Logo.iconset"
mkdir -p "$ICONSET"
for n in 16 32 128 256 512; do
  sips -s format png -z "$n" "$n" "$HERE/assets/MEGA-Logo.png" --out "$ICONSET/icon_${n}x${n}.png" >/dev/null 2>&1
  if [ "$n" -le 512 ]; then
    doubled=$((n * 2))
    sips -s format png -z "$doubled" "$doubled" "$HERE/assets/MEGA-Logo.png" --out "$ICONSET/icon_${n}x${n}@2x.png" >/dev/null 2>&1
  fi
done
if command -v iconutil >/dev/null 2>&1; then
  iconutil -c icns "$ICONSET" -o "$BUILT/Contents/Resources/MEGA-Logo.icns" || true
fi
# Ad-hoc signature for local builds. Published app should be signed/notarized for distribution.
if command -v codesign >/dev/null 2>&1; then codesign --force --sign - "$BUILT" >/dev/null 2>&1 || true; fi
if [ -e "$INSTALL.previous" ]; then rm -rf "$INSTALL.previous"; fi
if [ -e "$INSTALL" ]; then mv "$INSTALL" "$INSTALL.previous"; fi
cp -R "$BUILT" "$INSTALL"
# Remove only a project-created Desktop symlink from an older installer.
oldDesktop="$HOME/Desktop/$APP_NAME"
if [ -L "$oldDesktop" ]; then
  oldTarget=$(readlink "$oldDesktop")
  if [ "$oldTarget" = "$HOME/Applications/$APP_NAME" ] || [ "$oldTarget" = "$INSTALL" ]; then
    rm -f "$oldDesktop"
    report '[CLEANUP] Removed legacy project Desktop symlink.'
  fi
fi
if [ ! -f "$INSTALL/Contents/MacOS/TrunGameFreeMega" ]; then
  FAILURE_REASON='Compiled application executable is missing.'
  exit 1
fi
# Finder hides these support files, but the .app remains visible in the project folder.
for name in 'assets' 'macos' 'linux' 'windows' '.github' 'catalog.tsv' 'catalog-original.txt' 'credits.txt' \
            'Installer Windows.bat' 'Installer Linux.sh' 'Installer macOS.command' \
            'Repair Windows.bat' 'Repair Linux.sh' 'Repair macOS.command' \
            'README-EN.txt' 'README-PTBR.txt' 'TEST-RESULTS.txt' 'PREVIEW-LINUX.png'; do
  if [ -e "$HERE/$name" ]; then chflags hidden "$HERE/$name" || :; fi
done
if [ -e "$INSTALL.previous" ]; then rm -rf "$INSTALL.previous"; fi
report '[FILES] Compiled native SwiftUI app.'
report "[SHORTCUT] Application created INSIDE project folder: $INSTALL"
report '[DATA] DataSense in Application Support was preserved.'
SUCCESS=1
