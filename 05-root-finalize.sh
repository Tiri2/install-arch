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

# Setting up postgres
sudo -iu postgres initdb -D /var/lib/postgres/data
systemctl enable --now postgresql
cp /var/lib/postgres/data/postgresql.conf /var/lib/postgres/data/postgresql.conf.old
cat configs/postgres/postgresql.txt > /var/lib/postgres/data/postgresql.conf
cat configs/postgres/pg_hba.txt > /var/lib/postgres/data/pg_hba.conf

USER=whoami

if [[ $USER == "root" ]]; then
    loginctl enable-linger flex
fi

sudo -u flex systemctl --user enable flexLogMove.path
sudo -u flex systemctl --user enable flexLogMove.service
sudo -u flex systemctl --user enable bootlog.service

chmod 600 /etc/modprobe.d/*
echo "finished"
