#!/bin/bash

TZ="Europe/Vienna"
BOOTLOADER_ID=ARCH
BOOT_TARGET="/dev/sda"

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
/usr/bin/bash ./04-01-install-grub.sh $BOOTLOADER_ID $BOOT_TARGET

# Setting root password.
echo "Setting root password"
passwd

sed -i '/Color/s/^#//' /etc/pacman.conf

echo "Next Script will be 04-00-dir-structure"
