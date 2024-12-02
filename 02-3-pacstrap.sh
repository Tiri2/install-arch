#!/bin/bash

kernel=         # linux, linux-zen, linux-hardened; for example
microcode=      # amd-ucode or intel-ucode
hostname="PiServer"       # any random makeup names
locale="de_AT"  # uncomment this, if you want en_US; or en_GB is nice for metric units
kblayout="de-latin1"       # Can be omitted

if [ -z "$hostname" ]; then
    read -r -p "Please enter the hostname: " hostname
fi

if [ -z "$locale" ]; then
    read -r -p "Please insert the locale you use in this format (xx_XX): " locale
fi


if [ -z "$microcode" ]; then
    # Checking the microcode to install.
    CPU=$(grep vendor_id /proc/cpuinfo)
    if [[ $CPU == *"AuthenticAMD"* ]]
    then
        microcode=amd-ucode
    else
        microcode=intel-ucode
    fi
fi

if [ -z "$kernel" ]; then
    # Selecting the kernel flavor to install. 
    echo "List of kernels:"
    echo "1) Stable — Vanilla Linux kernel and modules, with a few patches applied."
    echo "2) Hardened — A security-focused Linux kernel."
    echo "3) Longterm — Long-term support (LTS) Linux kernel and modules."
    echo "4) Zen Kernel — Optimized for desktop usage."
    read -r -p "Insert the number of the corresponding kernel: " choice
    echo "$choice will be installed"
    case $choice in
        1 ) kernel=linux
            ;;
        2 ) kernel=linux-hardened
            ;;
        3 ) kernel=linux-lts
            ;;
        4 ) kernel=linux-zen
            ;;
        * ) echo "You did not enter a valid selection. Please try again"
            exit 1
    esac
fi

# Pacstrap (setting up a base sytem onto the new root).
echo "Installing the base system (it may take a while)."
pacstrap /mnt base base-devel "${kernel}" linux-firmware "${microcode}" efibootmgr grub grub-btrfs inotify-tools snapper snap-pac snap-sync git sudo nano firewalld rsync openssh zsh zsh-completions lsd fzf zoxide

# Generating /etc/fstab.
echo "Generating a new fstab."
genfstab -U /mnt >> /mnt/etc/fstab

sed -i -E '/subvol=\/@\/.snapshots\/1\/snapshot/s/,subvol.+/ 0 0/g' /mnt/etc/fstab
mount -a /mnt

# Setting hostname.
echo "$hostname" >> /mnt/etc/hostname

# Setting hosts file.
echo "Setting hosts file."
cat >> /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

# Setting up locales.
echo "$locale.UTF-8 UTF-8"  >> /mnt/etc/locale.gen
echo "LANG=$locale.UTF-8" >> /mnt/etc/locale.conf

if [ ! -z "$kblayout" ]; then
    echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf
fi

# Configuring /etc/mkinitcpio.conf
sed -i '/COMPRESSION="zstd"/s/^#//g' /mnt/etc/mkinitcpio.conf

echo "" >> /mnt/etc/default/grub
echo -e "# Booting with BTRFS subvolume\nGRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION=true" >> /mnt/etc/default/grub

sed -i '/GRUB_DISABLE_RECOVERY=/s/false/true/g' /mnt/etc/default/grub

sed -i 's#rootflags=subvol=${rootsubvol}##g' /mnt/etc/grub.d/10_linux
sed -i 's#rootflags=subvol=${rootsubvol}##g' /mnt/etc/grub.d/20_linux_xen

# Setting GRUB configuration file permissions
chmod 755 /mnt/etc/grub.d/*


