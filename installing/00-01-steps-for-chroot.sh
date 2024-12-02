echo "Am i running in a chroot environment?"
read -p "y/n" confirm

if [[ $confirm == "n" ]]; then
    echo "Please executing in chroot environment!"
    exit 1
fi

mount -a
lsblk

echo "Resizing btrfs filesystem"
btrfs filesystem resize max /

btrfs filesystem show /
btrfs filesystem usage /

# Break point to check if everything is all right
echo "CTRL + C to abort - Enter to continue"
read -p "Continue?"

source 03-01-install-grub.sh "$1" ARCH