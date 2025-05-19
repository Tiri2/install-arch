#!/usr/bin/env bash
set -euo pipefail

TMPDIR=$(mktemp -d -t firefox.XXXXXX)
# Tilde muss hier über $HOME expandieren
PROFILE="$HOME/.mozilla/profile"
CRASH_DIR="$TMPDIR/crash"

export MOZ_ENABLE_WAYLAND=1
export MOZ_CRASHREPORTER=1
export MOZ_CRASHREPORTER_DUMPDIR="$CRASH_DIR"
mkdir -p "$CRASH_DIR"

# Nur neu anlegen, wenn $PROFILE noch nicht existiert
if [ -d "$PROFILE" ]; then
  echo "Profil existiert bereits unter $PROFILE – erstelle kein neues."
else
  echo "Profil unter $PROFILE nicht gefunden – lege es an."
  firefox -CreateProfile "kiosk $PROFILE" >/dev/null
  mkdir -p "$PROFILE"
  # falls du hier gleich user.js einfügen willst, kannst du's direkt tun
  cat .config/firefox/user.js > "$PROFILE/user.js"
fi

# 5. Logfile vorbereiten und Firefox starten
LOGFILE="/var/log/gui/firefox.log"
echo "================================================" >> "$LOGFILE"

nice -n 10 firefox \
  --kiosk \
  --remote-debugging-port=2849 \
  --start-debugger-server ws:9222 \
  --profile "$PROFILE" \
  "file:///srv/http/gui/connecting/index.html?auto=1&retry=30" \
  &>> "$LOGFILE"
