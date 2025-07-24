#!/usr/bin/bash

roption=(
        --create
        --file=-
        --xattrs
        --absolute-names
        --use-compress-program=zstd
        --ignore-failed-read
)

configs=(
  /etc/mosquitto/
  /etc/caddy
  /var/lib/postgres/data/*.conf
  /etc/samba/smb.conf
  /etc/grafana.ini
  /etc/systemd/network/*.network
  /home/flex/.config/*
  /srv/http/
)

tar "${roption[@]}" \
    "${configs[@]}" 
