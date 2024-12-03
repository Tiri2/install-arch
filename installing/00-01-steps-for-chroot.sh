#!/bin/bash

echo " "
echo "Am i running in a chroot environment?"
read -p "y/n: " confirm

if [[ $confirm == "n" ]]; then
    echo "Please executing in chroot environment!"
    exit 1
fi

mount -a
lsblk

echo "Resizing btrfs filesystem"
btrfs filesystem resize max /

btrfs filesystem show /
btrfs filesystem usage /

# Break point to check if everything is all right
echo "Everything looking fine?"
echo "CTRL + C to abort - Enter to continue"
read -p "Continue?"

# TODO: Delete existing snapshots from master

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "DEBUG: script dir: ${SCRIPT_DIR}"
ls -al

# Installing Grub
source /root/install-grub.sh "$1" ARCH

echo "Making initramfs"
mkinitcpio -P

echo "Done. "