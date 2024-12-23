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
chmod -R 777 /var/system/tools

# Gui Specific
chown -R gui:gui /var/log/gui
chmod -R 744 /var/log/gui

# Configurator
chown -R :beer /var/system/tools/configurator
chmod 555 /var/system/tools/configurator/linux-configurator*
chmod 774 /var/system/tools/configurator/log4j2.xml

# Install-arch
chmod -R 755 /var/system/tools/install-arch

# Logs
chown flex:beer /var/log/system/boot.log
chmod 744 /var/log/system/boot.log

# Break point to check if everything is all right
echo "Everything looking fine?"
echo "CTRL + C to abort - Enter to continue"
read -p "Continue?"