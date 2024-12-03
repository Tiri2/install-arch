#!/bin/bash

# Überprüfen, ob ein Verzeichnis übergeben wurde
SNAPSHOT_DIR="$2"

echo "DEBUG: arg 1: ${1} - arg 2: ${2}"

if [[ -z "$SNAPSHOT_DIR" ]]; then
  echo "Fehler: Bitte ein Snapshot-Verzeichnis als Argument übergeben."
  exit 1
fi

if [[ ! -d "$SNAPSHOT_DIR" ]]; then
  echo "Fehler: Verzeichnis $SNAPSHOT_DIR existiert nicht."
  exit 1
fi

echo "Ermittle alle Snapshot-IDs im Verzeichnis $SNAPSHOT_DIR..."

# Liste der Snapshots abrufen und sortieren
snapshot_ids=$(btrfs subvolume list "$SNAPSHOT_DIR" | awk '{print $2}' | sort -n)

# Prüfen, ob Snapshots gefunden wurden
if [[ -z "$snapshot_ids" ]]; then
  echo "Keine Snapshots gefunden in $SNAPSHOT_DIR."
  exit 1
fi

# Letzte Snapshot-ID herausfinden
last_snapshot_id=$(echo "$snapshot_ids" | tail -n 1)
# Wichtigste Snapshot-ID definieren
important_snapshot_id="1"

echo "DEBUG: last_snapshot_id: ${last_snapshot_id}"
echo "DEBUG: snapshots_id: ${snapshot_ids}"

# Durchlaufen und Snapshots löschen, außer den letzten und wichtigsten
for snapshot_id in $snapshot_ids; do
  if [[ "$snapshot_id" == "$last_snapshot_id" || "$snapshot_id" == "$important_snapshot_id" ]]; then
    echo "Behalte Snapshot mit ID: $snapshot_id"
  else
    echo "Lösche Snapshot mit ID: $snapshot_id"
    btrfs subvolume delete -i "$snapshot_id" "$1" || {
      echo "Fehler beim Löschen von Snapshot $snapshot_id"; 
      exit 1; 
    }
  fi
done

echo "Nicht benötigte Snapshots wurden erfolgreich gelöscht."
