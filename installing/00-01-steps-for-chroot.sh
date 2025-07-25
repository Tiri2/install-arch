#!/bin/bash

echo " "
mount -a

echo "Resizing btrfs filesystem"
btrfs filesystem resize max / &>> /root/install.log

btrfs filesystem show /
btrfs filesystem usage /

# Break point to check if everything is all right
#echo "Everything looking fine?"
#echo "CTRL + C to abort - Enter to continue"
#read -p "Continue?"

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
sh /var/system/tools/install-arch/installing/01-deleting-snapshots.sh "/" "/.snapshots" &>> /root/install.log
sh /var/system/tools/install-arch/installing/01-deleting-snapshots.sh "/home" "/home/.snapshots" &>> /root/install.log
sh /var/system/tools/install-arch/installing/01-deleting-snapshots.sh "/srv" "/srv/.snapshots" &>> /root/install.log

snapper -c root create -d "Install Script" &>> /root/install.log
snapper -c home create -d "Install Script" &>> /root/install.log
snapper -c srv create -d "Install Script" &>> /root/install.log

# Installing Grub
sh /var/system/tools/install-arch/03-01-install-grub.sh "$1" ARCH

echo "Making initramfs"
mkinitcpio -P

# Remove config.json because tool should generate a new one
mv /var/system/config.json /var/system/config.json.from-master.json

# Removing .zsh_history because new host
rm /home/flex/.zsh_history
rm /root/.zsh_history

exit 0