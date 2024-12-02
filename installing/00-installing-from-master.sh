IP=10.1.1.69

if ! `/usr/bin/nc -w 5 "$IP" 22`; then 
    echo "Can not reach "$IP" - do u have a internet connection?"
    ip a
    ping -W 5 -c 2 "$IP"
    exit 1
fi

lsblk
echo "Please enter a valid disk for write the master on (/dev/sda)"
read -p "Disk: " DISK

echo "Before writing on ${DSIK} please provide the second partition to chroot into"
read -p "the second partiton (/dev/sda2): " PART2

read -p "Have you already installed a the master on this system? (y/n): " INSTALLED

if [[ $INSTALLED == "n" ]]; then
    echo "okay - installing system from master now..."
    echo "Take around 15 minutes"
    ssh root@"$IP" "dd if=/dev/sda bs=64M | gzip" | pv | gunzip | dd of=$DISK bs=64M
fi

echo "Resizing partiton 2 to maximum"
parted $DISK resizepart 2 100%

echo "Mounting ${PART2} and chroot into"
mount $PART2 /mnt
arch-chroot /mnt /bin/bash -c "00-01-steps-for-chroot.sh $DISK"