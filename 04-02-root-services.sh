#!/bin/bash

# Enabling Snapper automatic snapshots.
echo "Enabling Snapper and automatic snapshots entries."
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
systemctl enable grub-btrfsd.service

# Enabling systemd-networkd and sshd
systemctl enable systemd-networkd
systemctl enable sshd