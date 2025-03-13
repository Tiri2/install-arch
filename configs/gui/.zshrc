#!/usr/bin/zsh

has_physical_monitor=false

for output_dir in /sys/class/drm/card*-*; do
    if echo "$output_dir" | grep -i -qE "virtual|headless"; then
        continue
    fi

    edid_file="$output_dir/edid"
    if [ -f "$edid_file" ] && [ -s "$edid_file" ]; then
        has_physical_monitor=true
        break
    fi
done

# setup a fake monitor
if [ "$has_physical_monitor" = false ]; then
    export WLR_BACKENDS=headless
    export WLR_HEADLESS_OUTPUTS=1
    export WLR_HEADLESS_WIDTH=1920
    export WLR_HEADLESS_HEIGHT=1080
fi

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    echo "[$(date)] [INFO] starting sway and chromium" >> /var/log/gui/init.log

    # Das Letzte &-Zeichen sagt, dass der Prozess im Hintergrund laufen soll
    /usr/bin/sway -c ~/.config/sway/config &>> /var/log/gui/init.log &

    # sway etwas zeit geben zum starten, damit der wayland socket erstellt wird
    /usr/bin/sleep 5

    # Finde den korrekten Wayland-Socket
    WAYLAND_SOCKET=$(ls /run/user/$(id -u)/wayland-* | grep -E 'wayland-[0-9]+$')

    # Prüfe, ob ein gültiger Wayland-Socket gefunden wurde
    if [ -n "$WAYLAND_SOCKET" ]; then
        export WAYLAND_DISPLAY=$(basename "$WAYLAND_SOCKET")
        echo "[$(date)] [INFO] found Wayland-Socket $WAYLAND_DISPLAY" >> /var/log/gui/init.log
    else
        echo "[$(date)] [ERROR] No valid Wayland-Socket found!" >> /var/log/gui/init.log
    fi

    export XCURSOR_SIZE=24

    echo "[$(date)] [INFO] starting wayvnc" >> /var/log/gui/vnc.log
    /usr/bin/wayvnc --config /home/gui/.config/wayvnc/config &>> /var/log/gui/vnc.log
fi