#!/bin/bash

# Befehl zum einspielen: "unzstd <volume>.zst | btrfs receive /<volume>"

echo "======          Industruction             ======"
echo " "
echo " "
echo "These scripts writes a backup on the hard disk of this device. "
echo "If you want to install from the master use a other script instead of this."
echo " "

SUBVOLS=(
  "/srv"
  "/root"
  "/home"
  "/"
)

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cd $SCRIPT_DIR

function formatted() {
  if [[ ! -f "$HOME/.formatted" ]]; then
    return 1  # Nicht formatiert
  else
    return 0  # Bereits formatiert
  fi
}

# Format the hard disk
if ! formatted; then
  echo "executing 01-partitioning.sh"
  source ../../01-partitioning.sh

  echo "executing 02-1-format.sh"
  source ../../02-1-format.sh

  touch "$HOME/.formatted"
else
  echo "Disk already formatted, skipping..."
fi

BACKUP_DIR="/tmp/backup"

NEXT=0

# Check if the file is found, if not ask again
while [ $NEXT -eq 0 ]; do 
    echo "Please enter the full file path of the tar.gz backup file"
    read -p "file (/root/backup-Di-250107.tar.gz): " BACKUP_FILE

    echo "Checking if file exists..."
    echo "You entered ${BACKUP_FILE}"
    ls -al "$BACKUP_FILE"

    if [ -e "$BACKUP_FILE" ]; then
        NEXT=1  # Exit the loop
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
        NEXT=1  # Exit the loop
    fi
done

BACKUP_DIR="$BACKUP_DIR/tmp"

mkdir -p "$BACKUP_DIR/raw"

start=$(date +%s)

echo "Uncompressing the file $BACKUP_FILE"
tar -xf "$BACKUP_FILE" -C "$BACKUP_DIR/raw"

if [ $? -ne 0 ]; then
  echo "Fehler beim Entpacken von $BACKUP_FILE."
  exit 1
fi

end=$(date +%s)
runtime=$((end - start))
echo "Uncompressing the archiv "$BACKUP_FILE" took $runtime seconds." | tee -a "$LOGFILE"

echo "Archiv erfolgreich entpackt nach $BACKUP_DIR/raw."

# Alle Dateien mit der Endung .zst finden
ZST_FILES=($(find "$BACKUP_DIR/raw" -type f -name "*.zst"))

# Prüfen, ob Dateien gefunden wurden
if [ ${#ZST_FILES[@]} -eq 0 ]; then
  echo "Keine .zst-Dateien gefunden."
  exit 1
fi

for zst_file in "${ZST_FILES[@]}"; do
  echo "Verarbeite $zst_file..."

  # Ziel-Subvolume bestimmen
  case "$zst_file" in
    *rootfs.btrfs.zst)
      TARGET_SUBVOL="/"
      ;;
    *home.btrfs.zst)
      TARGET_SUBVOL="/home"
      ;;
    *root.btrfs.zst)
      TARGET_SUBVOL="/root"
      ;;
    *srv.btrfs.zst)
      TARGET_SUBVOL="/srv"
      ;;
    *)
      echo "Unbekannter Dateityp: $zst_file, überspringe..."
      continue
      ;;
  esac

  echo "Entpacke $zst_file und spiele es im Subvolume $TARGET_SUBVOL ein..."

  # Entpacken und in das Subvolume einspielen
  unzstd "$zst_file" | btrfs receive "/mnt$TARGET_SUBVOL"
  
  # Erfolg prüfen
  if [ $? -ne 0 ]; then
    echo "Fehler beim Einspielen von $zst_file in $TARGET_SUBVOL."
    exit 1
  else
    echo "$zst_file erfolgreich nach $TARGET_SUBVOL eingespielt."
  fi
done

# TODO den tar datei angeben und diese dann extrahieren und die einzelnen subvolumes dann via btrfs receive einspielen