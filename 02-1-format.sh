#!/bin/bash

BTRFS=""    # real partition e.g. /dev/vda2, /dev/sda2, or /dev/mapper/cryptroot
EXCLUDES=() # Array für auszuschließende Subvolumes

# Parse Argumente
while [[ $# -gt 0 ]]; do
    case "$1" in
    --exclude=*)
        # Extrahiere den Wert nach "--exclude="
        IFS=',' read -r -a EXCLUDES <<<"${1#*=}"
        ;;
    *)
        echo "Unknown argument: $1"
        exit 1
        ;;
    esac
    shift # Verschiebe die Argumentliste nach der Verarbeitung
done

# Debugging: Zeige die Werte in EXCLUDES an
echo "Excludes: ${EXCLUDES[@]}"


if [ -z "$BTRFS" ]; then
    read -r -p "Please choose the partition to format to BTRFS: " BTRFS
fi

if [ -z "$BOOT_PART" ]; then
    read -r -p "Please choose the EFI partition: " BOOT_PART
fi

mkfs.btrfs -f -L ARCH "$BTRFS"
mount "$BTRFS" /mnt

echo "Creating BTRFS subvolumes."

# Root Subvolume erstellen, falls nicht ausgeschlossen
if ! [[ " ${EXCLUDES[*]} " =~ " / " ]]; then
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@/.snapshots
    mkdir -p /mnt/@/.snapshots/1
    btrfs subvolume create /mnt/@/.snapshots/1/snapshot
fi

COW_VOLS=(
    home
    root
    srv
    var/log
    var/log/tasks
)
NOCOW_VOLS=(
    var/tmp
    var/cache
    .swap # If you need Swapfile, create in this folder
)

elem_in() {
    local e m="$1"
    shift
    for e in "$@"; do [[ "$m" == "$e" ]] && return 0; done
    return 1
}

for vol in "${COW_VOLS[@]}" "${NOCOW_VOLS[@]}"; do
    # Überspringe ausgeschlossene Volumes
    if [[ " ${EXCLUDES[*]} " =~ " /$vol " ]]; then
        echo "Skipping subvolume /$vol"
        continue
    fi

    btrfs subvolume create "/mnt/@/${vol//\//_}"
    mkdir -p "/mnt/$vol"

    if elem_in "$vol" "${NOCOW_VOLS[@]}"; then
        chattr +C "/mnt/@/${vol//\//_}"
    fi
done

# Set Default Subvolume nur, wenn "/" nicht ausgeschlossen ist
if ! [[ " ${EXCLUDES[*]} " =~ " / " ]]; then
    btrfs subvolume set-default "$(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+')" /mnt

    cat <<EOF >>/mnt/@/.snapshots/1/info.xml
<?xml version="1.0"?>
<snapshot>
    <type>single</type>
    <num>1</num>
    <date>2021-01-01 0:00:00</date>
    <description>First Root Filesystem</description>
    <cleanup>number</cleanup>
</snapshot>
EOF

    chmod 600 /mnt/@/.snapshots/1/info.xml
fi

umount /mnt

echo "Mounting the newly created subvolumes."

mount -o ssd,noatime,space_cache=v2,compress=zstd:15 "$BTRFS" /mnt

for vol in .snapshots "${COW_VOLS[@]}" "${NOCOW_VOLS[@]}"; do
    # Überspringe ausgeschlossene Volumes
    if [[ " ${EXCLUDES[*]} " =~ " /$vol " ]]; then
        continue
    fi

    mkdir -p "/mnt/$vol"
    mount -o "ssd,noatime,space_cache,autodefrag,compress=zstd:15,discard=async,subvol=@/${vol//\//_}" "$BTRFS" "/mnt/$vol"
done

mkdir -p /mnt/boot/efi
mount $BOOT_PART /mnt/boot/efi
