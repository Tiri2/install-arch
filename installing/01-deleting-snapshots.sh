#!/bin/bash

# Verzeichnis mit Snapshots als Argument übergeben
SNAPSHOT_DIR="$1"

# Überprüfen, ob das Verzeichnis existiert
if [[ -z "$SNAPSHOT_DIR" ]]; then
  echo "Fehler: Bitte das Verzeichnis der Snapshots als Argument übergeben."
  exit 1
fi

if [[ ! -d "$SNAPSHOT_DIR" ]]; then
  echo "Fehler: Verzeichnis $SNAPSHOT_DIR existiert nicht."
  exit 1
fi

echo "Prüfe Snapshots im Verzeichnis $SNAPSHOT_DIR..."

# Snapshots gezielt löschen, aber Standard-Snapshots behalten
for snapshot in "$SNAPSHOT_DIR"/*; do
  if [[ -d "$snapshot" ]]; then
    # Beispiel: Standard-Snapshots behalten, die mit "default" beginnen
    basename=$(basename "$snapshot")
    if [[ "$basename" == "default"* ]]; then
      echo "Überspringe Standard-Snapshot: $snapshot"
      continue
    fi

    echo "Lösche Snapshot: $snapshot"
    btrfs subvolume delete "$snapshot" || { echo "Fehler beim Löschen von $snapshot"; exit 1; }
  fi
done

echo "Nicht benötigte Snapshots wurden erfolgreich gelöscht."
