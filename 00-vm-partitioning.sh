#!/bin/bash

## Please enable UEFI first

loadkeys de-latin1

PART=  # /dev/vda for qemu, /dev/sda for VirtualBox

if [ -z "$PART" ]; then
    read -r -p "Please choose the partition name: " PART
fi

echo "Festplatte wird mit Nullern überschrieben"
dd if=/dev/zero of="$PART" bs=1M status=progess
sleep 2

parted "$PART" -- mklabel gpt

parted "$PART" -- mkpart ESP fat32 1MiB 512MiB
parted "$PART" -- mkpart primary 512MiB 100%

lsblk

mkfs.vfat "${PART}1"
