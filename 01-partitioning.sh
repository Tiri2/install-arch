#!/bin/bash

## Please enable UEFI first

PART=  # /dev/vda for qemu, /dev/sda for VirtualBox
BOOT_PART= # /dev/sda1 or /dev/nvme0n1p1

lsblk

if [ -z "$PART" ]; then
    read -r -p "Please choose the partition name: " PART
fi

parted "$PART" -- mklabel gpt

parted "$PART" -- mkpart ESP fat32 1MiB 512MiB
parted "$PART" -- mkpart primary 512MiB 100%

lsblk

if [ -z "$BOOT_PART" ]; then
    read -r -p "Please choose the boot partition: " PART
fi

mkfs.vfat "${BOOT_PART}"
