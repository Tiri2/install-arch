if ! `/usr/bin/nc -w 5 "10.1.1.70" 22`; then 
    echo "Can not reach 10.1.1.70 - do u have a internet connection?"
    ip a
    ping 10.1.1.70
    exit 1
fi

lsblk
echo "Please enter a valid disk for write the master on (/dev/sda)"
read -p "Disk: " DISK

echo "Before writing on ${DSIK} please provide the second partition to chroot into"
read "the second partiton (/dev/sda2): " PART2

ssh root@10.1.1.70 "dd if=/dev/sda bs=64M | gzip" | pv | gunzip | dd of=$DISK bs=64M

echo "Resizing partiton 2 to maximum"
parted $DISK resizepart 2 100%

echo "Mounting ${PART2} and chroot into"
mount $PART2 /mnt
arch-chroot /mnt /bin/bash -c "00-01-steps-for-chroot.sh $DISK"