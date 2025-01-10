#!/bin/bash

# Befehl zum einspielen: "unzstd <volume>.zst | btrfs receive /<volume>"

echo "======          Industruction             ======"
echo " "
echo " "
echo "These scripts writes a backup on the hard disk of this device. "
echo "If you want to install from the master use a other script instead of this."
echo " "

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd $SCRIPT_DIR

function formatted() {
  if [[ ! -f "$HOME/.formatted" ]]; then
    return 1 # Nicht formatiert
  else
    return 0 # Bereits formatiert
  fi
}

# Setting up the new host
echo "Please wait, the new system is setting currently up..."
if ! formatted; then
  echo "executing 01-partitioning.sh"
  source ../../01-partitioning.sh

  # echo "executing 02-1-format.sh"
  # source ../../02-1-format.sh --exclude="/srv,/root,/home,/"

  # echo "executing 02-2-updatepacman.sh"
  # source ../../02-2-updatepacman.sh

  # echo "executing 02-3-pacstrap.sh"
  # source ../../02-3-pacstrap.sh

  touch "$HOME/.formatted"
  echo "The System was setup correctly. Now copying the old subvolumes into the new ones"

  BTRFS=""    # real partition e.g. /dev/vda2, /dev/sda2, or /dev/mapper/cryptroot

  if [ -z "$BTRFS" ]; then
      read -r -p "Please choose the partition to format to BTRFS: " BTRFS
  fi

  if [ -z "$BOOT_PART" ]; then
      read -r -p "Please choose the EFI partition: " BOOT_PART
  fi

  mkfs.btrfs -f -L ARCH "$BTRFS"
  mount "$BTRFS" /mnt

else
  echo "Disk already formatted, skipping..."
fi

BACKUP_DIR="/tmp/backup"

NEXT=0

# Check if the file is found, if not ask again
while [ $NEXT -eq 0 ]; do
  echo "Before doing that, please provide the full path to the backup file."
  echo "You can exit the script with ctrl + c - current state will be saved"
  read -p "file (/root/backup-Di-250107.tar.gz): " BACKUP_FILE

  ls -al "$BACKUP_FILE"

  if [ -e "$BACKUP_FILE" ]; then
    NEXT=1 # Exit the loop
  else
    echo "Cannot find the file. Please try again!"
  fi
done

NEXT=0

NEXT=0

while [ $NEXT -eq 0 ]; do
  echo "Please enter a valid path to put the files temporarily down."
  read -p "Directory (/run/media/usb): " BACKUP_DIR

  if [ ! -d "$BACKUP_DIR" ]; then
    echo "No valid path. Please try again!"
    continue
  fi

  # Größe der Backup-Datei ermitteln (in KB)
  FILE_SIZE=$(du -k "$BACKUP_FILE" | cut -f1)

  # Verfügbaren Speicherplatz im Zielverzeichnis ermitteln (in KB)
  AVAILABLE_SPACE=$(df -k "$BACKUP_DIR" | awk 'NR==2 {print $4}')

  echo "File size: $FILE_SIZE KB"
  echo "Available space: $AVAILABLE_SPACE KB"

  # Überprüfen, ob genug Platz vorhanden ist
  if [ "$AVAILABLE_SPACE" -lt "$FILE_SIZE" ]; then
    echo "Not enough space in $BACKUP_DIR. Please try another directory!"
  else
    echo "Sufficient space available in $BACKUP_DIR."
    NEXT=1 # Exit the loop
  fi
done

BACKUP_DIR="$BACKUP_DIR/tmp"

mkdir -p "$BACKUP_DIR/raw"

start=$(date +%s)

echo "Dearchive the file $BACKUP_FILE"
tar -xf "$BACKUP_FILE" -C "$BACKUP_DIR/raw"

if [ $? -ne 0 ]; then
  echo "Error while dearchive $BACKUP_FILE."
  exit 1
fi

end=$(date +%s)
runtime=$((end - start))
echo "Dearchive the archiv "$BACKUP_FILE" took $runtime seconds."

echo "Archiv erfolgreich entpackt nach $BACKUP_DIR/raw."

# Alle Dateien mit der Endung .zst finden
# Sortiere ZST_FILES, sodass rootfs zuerst kommt
ZST_FILES=($(printf "%s\n" "${ZST_FILES[@]}" | sort -f | grep "rootfs.btrfs.zst"))
REST_FILES=($(printf "%s\n" "${ZST_FILES[@]}" | grep -v "rootfs.btrfs.zst"))
ZST_FILES=("${ZST_FILES[@]}" "${REST_FILES[@]}")

echo "$ZST_FILES"

# Break point to check if everything is all right
echo "CTRL + C to abort - Enter to continue"
read -p "Continue?"

# Prüfen, ob Dateien gefunden wurden
if [ ${#ZST_FILES[@]} -eq 0 ]; then
  echo "No files found in the archive!"
  exit 1
fi

for zst_file in "${ZST_FILES[@]}"; do
  echo "processing file $zst_file"

  # Datei prüfen
  if ! unzstd -t "$zst_file"; then
    echo "Error: $zst_file is not a valid zstd file or is corrupted."
    continue
  fi

  start=$(date +%s)

  # Temporäre Datei für entpackte Datei
  TEMP_FILE="$BACKUP_DIR/$(basename "$zst_file" .zst)"

  # Datei entpacken
  echo "Decompressing $zst_file to $TEMP_FILE..."
  unzstd -d "$zst_file" -o "$TEMP_FILE"

  if [ $? -ne 0 ]; then
    echo "Error decompressing $zst_file. Skipping..."
    continue
  fi

  # Ziel-Subvolume bestimmen
  case "$zst_file" in
    *rootfs.btrfs.zst)
      TARGET_SUBVOL="/mnt"
      ;;
    *home.btrfs.zst)
      TARGET_SUBVOL="/mnt/home"
      ;;
    *root.btrfs.zst)
      TARGET_SUBVOL="/mnt/root"
      ;;
    *srv.btrfs.zst)
      TARGET_SUBVOL="/mnt/srv"
      ;;
    *)
      echo "Unkown datatype: $zst_file, skipping..."
      continue
      ;;
  esac

  # Entpackte Datei mit btrfs receive einspielen
  echo "Sending $TEMP_FILE"
  btrfs receive "$TARGET_SUBVOL" <"$TEMP_FILE"

  mount "$BTRFS" "$TARGET_SUBVOL"

  # Erfolg prüfen
  if [ $? -ne 0 ]; then
    echo "Error while processing pushing into subvolume - $zst_file."
  else

    end=$(date +%s)
    runtime=$((end - start))

    # Temporäre Datei entfernen
    rm -f "$TEMP_FILE"

    echo "$zst_file successfully pushed into the subvolume."
    echo "This process took $runtime seconds."

  fi
done


# Create missing subvolumes
btrfs subvolume create /mnt/@/.snapshots
mkdir -p /mnt/@/.snapshots/1
btrfs subvolume create /mnt/@/.snapshots/1/snapshot


COW_VOLS=(
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

# Installing grub
echo "Installing grub on the new system to boot up"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
CURRENT_DIR=$(pwd)

if [[ "$SCRIPT_DIR" != "$CURRENT_DIR" ]]; then
  cd "$SCRIPT_DIR"
fi

# Coping files into chroot to execute them
cp ../../03-01-install-grub.sh /mnt/var/install-grub.sh
chmod +x /mnt/var/install-grub.sh

# Chroot into and exeute the copied sh script named setup.sh with args $DISK
arch-chroot /mnt /bin/bash -c "sh /var/install-grub.sh ARCH "$PART""


# Finish installation
echo "Installation from backup finished."

echo "Do you want to restart now?"
read -p "y/n: " RESTART

if [[ $RESTART == "y" ]]; then
  shutdown -r now
elif [[ $RESTART == "n" ]]; then
  echo "okay"
  exit 1
else
  echo "You may want to restart manual"
  exit 1
fi
