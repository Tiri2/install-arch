#!/bin/bash

# Creating flex user and configure him
echo "creating user flex"
useradd -m flex
cp configs/.zshrc /home/flex
chsh -s /usr/bin/zsh flex

echo "Entering password for flex"
passwd flex

# Creating gui user and configure him
echo "creating user gui"
useradd -m gui
cp configs/gui/.zshrc /home/gui
cp configs/gui/.start-chromium.sh /home/gui
chsh -s /usr/bin/zsh gui

mkdir -p /var/log/gui
touch /var/log/gui/init.log

mkdir -p /srv/http/gui/connecting
cp configs/gui/connecting-site.zip /srv/http/gui/connecting
unzip /srv/http/gui/connecting/connecting-site.zip -d /srv/http/gui/connecting

mkdir -p /home/gui/.config/sway
cp configs/gui/sway-config.txt /home/gui/.config/sway/config

mkdir -p /home/gui/.config/wayvnc
cp configs/gui/vnc/wayvnc-config.txt /home/gui/.config/wayvnc/config

mkdir -p /etc/systemd/system/getty@tty1.service.d
cat configs/gui/systemd/getty@tty1.service.txt > /etc/systemd/system/getty@tty1.service.d/override.conf.disabled
systemctl enable getty@tty1.service

# installing sway for gui user
pacman -S --noconfirm sway xorg-xwayland tigervnc chromium libinput evtest

# not working
# cat configs/gui/systemd/x0vncserver.service.txt > /etc/systemd/system/system.x0vncserver.service
# systemctl enable system.x0vncserver.service

# Break point to check if everything is all right
echo "Everything looking fine?"
echo "CTRL + C to abort - Enter to continue"
read -p "Continue?"

# Setting up needed files for tasks
mkdir -p /home/flex/.config/systemd/user
mkdir -p /srv/tasks/CURRENT/.config/

cat configs/flexTasks/log4j2.txt > /srv/tasks/CURRENT/default/log4j2.xml
cat configs/flexTasks/flexTasks.conf.txt > /srv/tasks/CURRENT/.config/flexTasks.conf
cat configs/flexTasks/task.template.service.txt > /home/flex/.config/systemd/user/task.template.service
cat configs/flexTasks/flexTasks.slice.txt > /home/flex/.config/systemd/user/flexTasks.slice

# Setting up daily backup
cat configs/system/backup/system.backup.service.txt > /etc/systemd/system/system.backup.service
cat configs/system/backup/system.backup.timer.txt > /etc/systemd/system/system.backup.timer
cat configs/system/backup/backup.sh.txt > /var/system/scripts/backup.sh
cat backup/00-create-backup.sh > /var/system/scripts/backup-full.sh

# Setup flexcert
cat configs/system/flexcert.sh.txt > /var/system/scripts/flexcert.sh
chown 666 /var/system/scripts/flexcert.sh
ln -sf /var/system/scripts/flexcert.sh /usr/bin/flexcert

# Configure root user
cp configs/.zshrc /root
chsh -s /usr/bin/zsh root

# Setting up system services
# bootlog service
cat configs/system/bootlog/bootlog.sh.txt > /var/system/scripts/bootlog.sh
cat configs/system/bootlog/shutdown.sh.txt > /var/system/scripts/shutdown.sh
cat configs/system/bootlog/bootlog.service.txt > /etc/systemd/system/system.bootlog.service
mkdir -p /var/log/system/
touch /var/log/system/boot.log

# LogManage
cat configs/system/log/ManageLogs.service.txt > /etc/systemd/system/system.manageLogs.service
cat configs/system/log/ManageLogs.sh.txt > /var/system/scripts/ManageLogs.sh

# Configurator
echo "Setting up configurator"
mkdir -p /var/system/tools/configurator/
touch /var/log/system/configurator.log
cat configs/configurator/log4j2.xml.txt > /var/system/tools/configurator/log4j2.xml
cat configs/configurator/configurator.path.txt > /etc/systemd/system/system.configurator.path
cat configs/configurator/configurator.service.txt > /etc/systemd/system/system.configurator.service
cp configs/configurator/linux-configurator-1.0.0-SNAPSHOT.jar /var/system/tools/configurator
ln -sf /var/system/tools/configurator/linux-configurator-1.0.0-SNAPSHOT.jar /var/system/tools/configurator/configurator.jar

# Fully upgrading the system
echo "Upgrading System"
pacman -Syu

# Break point to check if everything is all right
echo "CTRL + C to abort - Enter to continue"
read -p "Continue?"

echo "installing java openjdk 17 and other related things"
pacman -S --noconfirm java-runtime-common java-environment-common jdk17-openjdk

echo "new installed Java Version: "
java -version

# Installing needed packages and configure them for our flex tasks
echo "installing and setuping up mosquitto"
pacman -S --noconfirm mosquitto
cat configs/mosquitto.txt > /etc/mosquitto/mosquitto.conf

echo "installing and setting up samba server"
pacman -S --noconfirm samba
cat configs/samba.txt > /etc/samba/smb.conf

echo "installing and setting up caddy server"
pacman -S --noconfirm caddy
cat configs/caddyfile.txt > /etc/caddy/Caddyfile

echo "Setting up systemd-networkd and resolve.conf"
cat configs/systemd-network.txt > /etc/systemd/network/10-ethernet.network
cat configs/resolve.txt > /etc/resolv.conf

echo "Setting up postgres"
pacman -S --noconfirm postgresql
echo "Postgres will be configured in 05-root-finalize.sh"

echo "Setting up sudoers"
cp /etc/sudoers /etc/sudoers.old
cat configs/sudoers.txt > /etc/sudoers

echo "installing and setting up sqlite3"
pacman -S --noconfirm sqlite3
cat configs/.sqliterc > /home/flex/.sqliterc

# User Services enablen
systemctl --user enable default.target
