if [ -z "$2" ]; then
    read -r -p "Please choose a target (/dev/sda): " $2
fi

if [ -z "$1" ]; then
    read -r -p "Please enter the valid bootloader-id (ARCH): " $1
fi


# Installing GRUB.
echo "Installing GRUB on /boot."

GRUB_MODULES="normal test efi_gop efi_uga search echo linux loadenv configfile gzio part_gpt btrfs"

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="$1" --modules="$GRUB_MODULES" --disable-shim-lock "$2"

# Creating grub config file.
echo "Creating GRUB config file."
grub-mkconfig -o /boot/grub/grub.cfg