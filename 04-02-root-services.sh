#!/bin/bash

# Enabling Snapper automatic snapshots.
echo "enabling Snapper and automatic snapshots entries."
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
systemctl enable grub-btrfsd.service

# Enabling systemd-networkd and sshd
echo "enabling systemd-networkd and sshd"
systemctl enable systemd-networkd
systemctl enable sshd

# Enabling services needed for tasks (04-01-init-tasks.sh)
echo "enabling services needed for tasks (04-01-init-tasks.sh)"
systemctl enable smb
systemctl enable mosquitto
systemctl enable caddy

# Setting up configurator
echo "Setting up configurator"
mkdir -p /var/system/tools/configurator/
cat configs/configurator/log4j2.xml.txt > /var/system/tools/configurator/log4j2.xml
cat configs/configurator/configurator.path.txt > /etc/systemd/system/system.configurator.path
cat configs/configurator/configurator.service.txt > /etc/systemd/system/system.configurator.service
cp configs/configurator/linux-configurator-1.0.0-SNAPSHOT.jar /var/system/tools/configurator
ln -sf /var/system/tools/configurator/linux-configurator-1.0.0-SNAPSHOT.jar configurator.jar
systemctl enable system.configurator.path