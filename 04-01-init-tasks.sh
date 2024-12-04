#!/bin/bash

# Creating flex user and configure him
echo "creating user flex"
useradd -m flex
cp misc/.zshrc /home/flex
chsh -s /usr/bin/zsh flex

echo "Entering password for flex"
passwd flex

# Setting up needed files for tasks
mkdir -p /home/flex/.config/systemd/user
mkdir -p /srv/tasks/CURRENT/.config/env.d

cat configs/flexTasks/log4j2.txt > /srv/tasks/CURRENT/default/log4j2.xml
cat configs/flexTasks/flexTasks.conf.txt > /srv/tasks/CURRENT/.config/env.d/flexTasks.conf
cat configs/flexTasks/template.service.txt > /home/flex/.config/systemd/user/template.service
cat configs/flexTasks/flexTasks.slice.txt > /home/flex/.config/systemd/user/flexTasks.slice

# Setting up bootlog service
cat configs/system/bootlog.sh.txt > /var/system/scripts/bootlog.sh
cat configs/system/bootlog.service.txt > /home/flex/.config/systemd/user/bootlog.service

# Setting up flexLogMove
cat configs/system/log/flexLogMove.path.txt > /home/flex/.config/systemd/user/flexLogMove.path
cat configs/system/log/flexLogMove.service.txt > /home/flex/.config/systemd/user/flexLogMove.service
cat configs/system/log/flexLogMove.sh.txt > /var/system/scripts/flexLogMove.sh

# Configure root user
cp misc/.zshrc /root
chsh -s /usr/bin/zsh root

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
cat configs/caddyfile.txt > /etc/caddy/CaddyFile

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
cat misc/.sqliterc > /home/flex/.sqliterc

# User Services enablen
systemctl --user enable default.target
