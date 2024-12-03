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

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

cd "$SCRIPT_DIR"
ls -al "$SCRIPT_DIR"

echo "Cloning git repo from tiri2/install-arch"
mkdir -p /var/system/tools/
git clone https://github.com/Tiri2/install-arch.git /var/system/tools/install-arch/

# Delete existings snapshots
sh /var/system/tools/install-arch/installing/01-deleting-snapshots.sh /mnt/@/.snapshots
sh /var/system/tools/install-arch/installing/01-deleting-snapshots.sh /mnt/@home/.snapshots

# Installing Grub
sh /var/system/tools/install-arch/03-01-install-grub.sh "$1" ARCH

echo "Making initramfs"
mkinitcpio -P

echo "Done. "