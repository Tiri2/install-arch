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
# allowing smb port
firewall-cmd --permanent --add-port=445/tcp --zone=public
# allowing netbios ports
firewall-cmd --permanent --add-port=139/tcp --zone=public
firewall-cmd --permanent --add-port=137/udp --zone=public
firewall-cmd --permanent --add-port=138/udp --zone=public

# Reloading firewall
echo "ports opened - reloading firewall..."
firewall-cmd --reload

chmod 600 /etc/modprobe.d/*
echo "finished"
