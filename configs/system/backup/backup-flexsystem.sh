#!/usr/bin/bash

roption=(
        --create
        --file=-
        --xattrs
        --absolute-names
        --use-compress-program=zstd
        --ignore-failed-read        # fehlende Pfade überspringen
)

# Nur die reinen Config-Dateien, keine Datenverzeichnisse
configs=(
  /etc/mosquitto/
  /etc/caddy
  /var/lib/postgres/data/*.conf
  /etc/samba/smb.conf
  /etc/grafana.ini
  /etc/systemd/network/*.network
)

# Backup starten:
# 1) Einträge aus backup.include
# 2) alle Config-Pfade (wird übersprungen, wenn’s sie nicht gibt)
# 3) alle .db in /srv/tasks/CURRENT nach foption
tar "${roption[@]}" \
    "${configs[@]}" 
