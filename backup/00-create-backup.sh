#!/usr/bin/env bash

# Define which subvolumes to backup
SUBVOLS=(
  "/srv"
  "/root"
  "/home"
  "/"
)

BACKUP_DIR="/srv/backup/backup-$(date +%a-%y%m%d)"
LOGFILE="${BACKUP_DIR}/mkbackup.log"

if [ -d "$BACKUP_DIR" ]; then
  ls -al "$BACKUP_DIR"
  rm -r "$BACKUP_DIR"
fi

mkdir -p "$BACKUP_DIR"
touch "$LOGFILE"

for subvol in "${SUBVOLS[@]}"; do
  # create snapshot readonly

  if [ "$subvol" == "/" ]; then
    subvol="/rootfs"
  fi

  path="$BACKUP_DIR$subvol"

  echo "Snapshot Path: $path" | tee -a "$LOGFILE"
  echo "creating snapshot" | tee -a "$LOGFILE"
  btrfs subvolume snapshot -r "$subvol" "$path" 2>> "$LOGFILE"

  if [[ $? -ne 0 ]]; then
    echo "Error while creating snapshot"
  fi

  start=$(date +%s)
  
  echo "Compress subvolume and save it to ${subvol}.btrfs.zst" | tee -a "$LOGFILE"
  btrfs send "$path" 2>> "$LOGFILE" | zstd -9 -o "$BACKUP_DIR$subvol".btrfs.zst 2>> "$LOGFILE"

  end=$(date +%s)
  runtime=$((end - start))
  echo "Compressing subvolume took $runtime seconds." | tee -a "$LOGFILE"

  sleep 0.5

  # Break point to check if everything is all right
  echo "CTRL + C to abort - Enter to continue"
  read -p "Continue?"

  echo "deleting snapshot" | tee -a "$LOGFILE"
  btrfs subvolume delete "$path" 2>> "$LOGFILE"

  if [[ $? -ne 0 ]]; then
    echo "Error while deleting snapshot"
  fi
  
  
done

ARCHIVE_FILE="backup-$(date +%a-%y%m%d)-$(cat /etc/hostname).tar.gz"

echo "archive all compressed subvolume files" | tee -a "$LOGFILE"
tar -cf "$BACKUP_DIR/$ARCHIVE_FILE" "$BACKUP_DIR"/*.zst

echo "all files are saved in $ARCHIVE_FILE" | tee -a "$LOGFILE"

