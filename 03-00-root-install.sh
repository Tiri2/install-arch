#!/bin/bash

TZ="Europe/Vienna"
BOOTLOADER_ID=ARCH
BOOT_TARGET=""

lsblk

if [ -z "$BOOT_TARGET" ]; then
    read -r -p "Please choose the boot target (mostly /dev/sda): " BOOT_TARGET
fi

# Setting up timezone.
ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime

# Setting up clock.
hwclock --systohc

# Generating locales.
echo "Generating locales."
locale-gen

# Generating a new initramfs.
echo "Creating a new initramfs."
chmod 600 /boot/initramfs-linux*
mkinitcpio -P

# Snapper configuration
echo "Do snapper configuration"
umount /.snapshots
rm -r /.snapshots
snapper --no-dbus -c root create-config /
snapper --no-dbus -c home create-config /home
snapper --no-dbus -c srv create-config /srv
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
chmod 750 /.snapshots

echo "ATTENTION!! Executing following script: 04-01-install-grub.sh"
# Executing a nother script with the args as descriped above
source ./03-01-install-grub.sh $BOOTLOADER_ID $BOOT_TARGET

NEXT=0

while [$NEXT == 0]
do 
    # Setting root password.
    echo "Setting root password"
    passwd

    # Break point to check if everything is all right
    echo "Root password correct set?"
    read -p "y/n" ANSWER

    if [[ $ANSWER == "y" ]]; then
        NEXT = 0
    fi
done


sed -i '/Color/s/^#//' /etc/pacman.conf

echo "Next Script will be 04-00-dir-structure"
