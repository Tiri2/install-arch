#!/usr/bin/env bash
set -euo pipefail

TMPDIR=$(mktemp -d -t firefox.XXXXXX)
PROFILE="$TMPDIR/profile"
CRASH_DIR="$TMPDIR/crash"

export MOZ_ENABLE_WAYLAND=1

export MOZ_CRASHREPORTER=1
export MOZ_CRASHREPORTER_DUMPDIR="$CRASH_DIR"
mkdir -p "$CRASH_DIR"

firefox -CreateProfile "kiosk $PROFILE" >/dev/null
mkdir -p "$PROFILE"

cat .config/firefox/user.js > "$PROFILE/user.js" 

# 5. Logfile vorbereiten und Firefox starten
LOGFILE="/var/log/gui/firefox.log"
echo "================================================" >>"$LOGFILE"

nice -n 10 firefox \
    --kiosk \
    --remote-debugging-port=2849 \
    --start-debugger-server ws:9222 \
    --profile "$PROFILE" \
    "file:///srv/http/gui/connecting/index.html?auto=1&retry=30" \
    &>>"$LOGFILE"
