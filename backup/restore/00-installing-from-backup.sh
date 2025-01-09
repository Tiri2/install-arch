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
        echo "Cannot find the file. Please try again!"
    fi
done

mkdir -p "$BACKUP_DIR"

tar -xzf "$BACKUP_FILE" -C "$BACKUP_DIR/raw"

if [ $? -ne 0 ]; then
  echo "Fehler beim Entpacken von $BACKUP_FILE."
  exit 1
fi

echo "Archiv erfolgreich entpackt nach $BACKUP_DIR/raw."

# Alle Dateien mit der Endung .zst finden
ZST_FILES=($(find "$BACKUP_DIR/raw" -type f -name "*.zst"))

# Prüfen, ob Dateien gefunden wurden
if [ ${#ZST_FILES[@]} -eq 0 ]; then
  echo "Keine .zst-Dateien gefunden."
  exit 1
fi

echo "Gefundene .zst-Dateien:"
for file in "${ZST_FILES[@]}"; do
  echo "$file"
done

# Jetzt kannst du die Variable ZST_FILES iterieren oder für weitere Verarbeitung nutzen
# Beispiel: Iteration über alle Dateien
for zst_file in "${ZST_FILES[@]}"; do
  echo "Verarbeite $zst_file..."
  # Hier kannst du etwas mit jeder Datei machen, z.B. entpacken
done

# TODO den tar datei angeben und diese dann extrahieren und die einzelnen subvolumes dann via btrfs receive einspielen