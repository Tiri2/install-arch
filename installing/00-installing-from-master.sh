#!/bin/bash

IP=10.1.1.70

echo "======          Industruction             ======"
echo " "
echo " "
echo "These scripts writes the master image on the hard disk of this device. "
echo "If you want to install from a backup use a other script instead of this."
echo " "

# Getting disk from user to write the master disk on
echo "Please enter a valid disk for write the master on (/dev/sda)"
read -p "Disk: " DISK
echo " "

# Reqeust if anything is already installed. If not installing from master
read -p "Have you already installed the master on this system? (y/n): " INSTALLED
echo " "
if [[ $INSTALLED == "n" ]]; then

    if ! ping -c 1 -w 5 $IP &> /dev/null; then 
        echo "Can not reach "$IP" - do u have a internet connection?"
        exit 1
    fi

    echo "okay - installing system from master now..."
    echo "Take around 15 minutes"
    ssh root@"$IP" "dd if=/dev/sda bs=64M | gzip" | pv | gunzip | dd of=$DISK bs=64M
fi

echo "Resizing partiton 2 to maximum"
parted $DISK resizepart 2 100%

echo " "
echo " "

lsblk

echo " "
# Getting second partiton from user
echo "Before writing on ${DISK} please provide the second partition to chroot into"
read -p "the second partiton (/dev/sda2): " PART2
echo " "

# Getting into folder where the script is
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
CURRENT_DIR=$(pwd)

if [[ "$SCRIPT_DIR" != "$CURRENT_DIR" ]]; then
  cd "$SCRIPT_DIR"
fi

# Mounting partition 2 to chroot into 
# and then executing 00-01-steps-for-chroot.sh (setup.sh)
echo "Mounting ${PART2} and chroot into"
mount $PART2 /mnt

# Coping files into chroot to execute them
cp 00-01-steps-for-chroot.sh /mnt/root/setup.sh
chmod +x /mnt/root/setup.sh

# Chroot into and exeute the copied sh script named setup.sh with args $DISK and $PART2
arch-chroot /mnt /bin/bash -c "sh /root/setup.sh "$DISK" "$PART2""