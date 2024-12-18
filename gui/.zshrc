if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    echo "[$(date)] [INFO] starting sway and chromium" >> /var/log/gui/init.log
    
    exec sway -c ~/.config/sway/config &>> /var/log/gui/init.log

    # Finde den korrekten Wayland-Socket
    WAYLAND_SOCKET=$(ls /run/user/$(id -u)/wayland-* | grep -E 'wayland-[0-9]+$')

    # Prüfe, ob ein gültiger Wayland-Socket gefunden wurde
    if [ -n "$WAYLAND_SOCKET" ]; then
        export WAYLAND_DISPLAY=$(basename "$WAYLAND_SOCKET")
        echo "[$(date)] [INFO] found Wayland-Socket $WAYLAND_DISPLAY" >> /var/log/gui/init.log
    else
        echo "[$(date)] [ERROR] No valid Wayland-Socket found!" >> /var/log/gui/init.log
    fi
fi

