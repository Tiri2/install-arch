IP=10.1.1.69

echo "Trying to ping ${IP}"
if ! ping -c 1 -w 5 $IP &> /dev/null; then 
    echo "Can not reach "$IP" - do u have a internet connection?"
    ip a
    ping -W 5 -c 2 "$IP"
    exit 1
fi

lsblk

echo " "
echo " "

echo "Please enter a valid disk for write the master on (/dev/sda)"
read -p "Disk: " DISK
echo " "

echo "Before writing on ${DSIK} please provide the second partition to chroot into"
read -p "the second partiton (/dev/sda2): " PART2
echo " "

read -p "Have you already installed the master on this system? (y/n): " INSTALLED
echo " "

if [[ $INSTALLED == "n" ]]; then
    echo "okay - installing system from master now..."
    echo "Take around 15 minutes"
    ssh root@"$IP" "dd if=/dev/sda bs=64M | gzip" | pv | gunzip | dd of=$DISK bs=64M
fi

echo "Resizing partiton 2 to maximum"
parted $DISK resizepart 2 100%

echo "Mounting ${PART2} and chroot into"
mount $PART2 /mnt
# Coping files into chroot to execute them
cp 00-01-steps-for-chroot.sh /mnt/root/setup.sh
chmod +x /mnt/root/setup.sh
cp 03-01-install-grub.sh /mnt/root/install-grub.sh
chmod +x /mnt/root/setup.sh

arch-chroot /mnt /bin/bash -c "sh /root/setup.sh $DISK"