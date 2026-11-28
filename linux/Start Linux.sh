#!/bin/sh
set -eu
APP_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if ! command -v wish >/dev/null 2>&1; then
  printf '%s\n' 'Trun Game Free Mega requires Tcl/Tk (wish).' 'On Ubuntu/Debian: sudo apt install tk' 'On Fedora: sudo dnf install tk'
  exit 1
fi
exec wish "$APP_DIR/linux/TrunGameFreeMega.tcl"
