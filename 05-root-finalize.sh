#!/bin/bash

echo "Is this script running after installation or current installation?"
read -p "a (after) / c (current): " WHEN_RUNNING

if [[ $WHEN_RUNNING == "c" ]]; then 
    echo "Please run this script after installation to finalize this process."
    exit 1
fi

# Setting up firewalld
echo "setting up firewalld"

echo "starting and enabling firewalld"
systemctl enable --now firewalld

firewall-cmd --list-all
# allowing ssh port
firewall-cmd --permanent --add-service=ssh --zone=public
firewall-cmd --permanent --add-service=postgresql --zone=public
firewall-cmd --permanent --add-service=http --zone=public
firewall-cmd --permanent --add-service=https --zone=public
# allowing smb port
firewall-cmd --permanent --add-port=445/tcp --zone=public
# allowing netbios ports
firewall-cmd --permanent --add-port=139/tcp --zone=public
firewall-cmd --permanent --add-port=137/udp --zone=public
firewall-cmd --permanent --add-port=138/udp --zone=public
firewall-cmd --permanent --add-port=8150/tcp --zone=public

# Reloading firewall
echo "ports opened - reloading firewall..."
firewall-cmd --reload

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd $SCRIPT_DIR


USER=whoami

if [[ $USER == "root" ]]; then
    loginctl enable-linger flex
fi

groupadd -U flex beer

# Deleting temp files
echo "Deleting temp files"
rm /root/setup.sh

# Deleting bash files - we use zsh instead
rm /home/flex/.bash*

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
chown flex:flex /home/flex/.config
chown flex:flex /home/flex/.config/systemd
chown flex:flex /home/flex/.zshrc
chown flex:flex /home/flex/.sqliterc

# System specifc
chown -R :beer /var/system/
chmod 655 /var/system/scripts/*
chmod 770 /var/system/backup
chmod 770 /var/system/certs
chmod 775 /var/system/tools

echo "Installing missing packages"
pacman -Sy --noconfirm htop btop ripgrep less curl iputils net-tools bind rsync tcpdump wget zstd jq polkit

echo "Setting up postgres"
# Setting up postgres
sudo -iu postgres initdb -D /srv/postgres
systemctl enable --now postgresql
cp /srv/postgres/postgresql.conf /srv/postgres/postgresql.conf.old
cp /srv/postgres/pg_hba.conf /srv/postgres/pg_hba.conf.old
cat configs/postgres/postgresql.txt > /srv/postgres/postgresql.conf
cat configs/postgres/pg_hba.txt > /srv/postgres/pg_hba.conf
systemctl restart postgresql

# Not working - must be logged in as flex
# echo "Starting required user services"
# systemctl --user enable flexLogMove.path
# systemctl --user enable flexLogMove.service
# systemctl --user enable bootlog.service

# Creating boots log file
mkdir -p "/var/log/system/"
touch /var/log/system/boot.log

chmod 600 /etc/modprobe.d/*
echo "finished"
