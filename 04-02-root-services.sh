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