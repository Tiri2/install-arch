# Temp Dir
TMPDIR=$(mktemp -d -t chrome.XXXXXX)

# Start Chromium
choption=(
    --kiosk
    --incognito
    --no-first-run
    --app-auto-launched
    --ozone-platform=wayland
    --user-data-dir=$TMPDIR/userdata
    --crash-dumps-dir=$TMPDIR/crash
    --disk-cache-dir=$TMPDIR/cache
    --start-maximized
    --enable-logging=stderr 
    --v=1
    --disable-infobars
    --disable-databases
    --disable-local-storage
    --disable-origin-trial-controlled-blink-features
    --disable-oopr-debug-crash-dump
    --disable-pepper-3d
    --disable-pinch
    --disable-print-preview
    --disable-dinosaur-easter-egg
    --disable-extensions
    --disable-first-run-ui
    --disable-new-bookmark-apps
    --disable-presentation-api
    --disable-print-preview
    --disable-notifications
    --disable-popup-blocking
    --disable-prompt-on-repost
    --disable-breakpad
    --disable-domain-reliability
    --disable-save-password-bubble
    --disable-stack-profiler
    --disable-features=InterestFeedContentSuggestions
    --disable-features=CalculateNativeWinOcclusion
    --disable-features=HeavyAdPrivacyMitigations
    --disable-features=LazyFrameLoading
    --disable-features=Translate
    --disable-features=GlobalMediaControls
    --disable-features=site-per-process
    --disable-features=Translate
#   --disable-features=CrossSiteDocumentBlockingAlways
#   --disable-features=CrossSiteDocumentBlockingIfIsolating
    --disable-web-security
    --no-default-browser-check
    --dns-prefetch-disable
    --remote-debugging-address=10.200.1.66
    --remote-debugging-port=9222
)

echo "================================================" >> /var/log/gui/chromium.log
nice -n 10 /usr/bin/chromium --app=file:"///srv/http/gui/connecting/index.html?auto=1&retry=30" "${choption[@]}" &>> /var/log/gui/chromium.log
