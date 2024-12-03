#!/bin/bash


echo "======          Industruction             ======"
echo " "
echo " "
echo "This scripts only execute the other scripts. "
echo "If you want to install from the master use a other script instead of this."
echo " "

echo "executing 00-vm-partitioning.sh"
source 00-vm-partitioning.sh

echo "executing 02-1-format.sh"
source 02-1-format.sh

echo "executing 02-2-updatepacman.sh"
source 02-2-updatepacman.sh

echo "executing 02-3-pacstrap.sh"
source 02-3-pacstrap.sh

echo "Copying needed files to new system"
cp -01-01-installing-fresh-master-in-chroot.sh /mnt/root/setup.sh
chmod +x /mnt/root/setup.sh

echo "Chroot into the newly created system"
arch-chroot /mnt /bin/bash -c "sh /root/setup.sh"