#!/bin/bash

echo "arg 1: ${1} - arg 2: ${2}"
echo " "
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

# Cd into Script dir
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$SCRIPT_DIR"

echo "Fetch git repo from tiri2/install-arch"
mkdir -p /var/system/tools/

if [[ -d "/var/system/tools/install-arch/" ]]; then
    git -C /var/system/tools/install-arch/ pull &> /dev/null
else
    git clone https://github.com/Tiri2/install-arch.git /var/system/tools/install-arch/ &> /dev/null
fi

# Delete existings snapshots
sh /var/system/tools/install-arch/installing/01-deleting-snapshots.sh "/mnt" "/.snapshots"
sh /var/system/tools/install-arch/installing/01-deleting-snapshots.sh "/mnt/home" "/home/.snapshots"
sh /var/system/tools/install-arch/installing/01-deleting-snapshots.sh "/mnt/srv" "/srv/.snapshots"

snapper -c root create -d "Install Script"
snapper -c home create -d "Install Script"
snapper -c srv create -d "Install Script"

# Installing Grub
sh /var/system/tools/install-arch/03-01-install-grub.sh "$1" ARCH

echo "Making initramfs"
mkinitcpio -P

echo "Done. Installing succuessfully - do you want to restart now?"
read -p "y/n: " RESTART

if [[ $RESTART == "y" ]]; then
    shutdown -r now
elif [[ $RESTART == "n" ]]; then
    echo "okay"
    exit 1
else 
    exit 1
fi