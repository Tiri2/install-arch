#!/bin/bash

echo "Set perms for directories"

groupadd -U flex beer

# Deleting temp files
echo "Deleting temp files"
rm /root/setup.sh

# Deleting bash files - we use zsh instead
rm /home/flex/.bash*
rm /home/gui/.bash*

# Settings rights
echo "Settings missing rights"
chmod 644 /home/flex/.config/systemd/user/*
chown -R flex:flex /home/flex/.config/systemd/user/

# For /srv/
chmod 775 /srv/ftp
chmod 775 /srv/http
chmod 775 /srv/smb
chmod 775 /srv/tasks

chown -R :beer /srv/
chmod -R g+rwx /srv/
chmod -R o+rx /srv/

# For home user specifc

# flex
chown flex:flex /home/flex/.config
chown flex:flex /home/flex/.config/systemd
chown flex:flex /home/flex/.zshrc
chown flex:flex /home/flex/.sqliterc

# gui
chown -R gui:gui /home/gui
chown -R gui:beer /srv/http/gui/connecting

# System specifc
chown -R :beer /var/system/
chmod 655 /var/system/scripts/*
chmod 770 /var/system/backup
chmod 770 /var/system/certs
chmod 775 /var/system/tools
chmod 766 /var/system/tools/