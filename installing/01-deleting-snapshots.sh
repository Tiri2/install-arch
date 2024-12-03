#!/bin/bash

SNAPSHOT_DIR="$1"

if [[ -z "$SNAPSHOT_DIR" ]]; then
  echo "Error: Please specify a snapshot directory."
  exit 1
fi

if [[ ! -d "$SNAPSHOT_DIR" ]]; then
  echo "Error: Directory $SNAPSHOT_DIR does not exist."
  exit 1
fi

echo "Checking snapshots in directory $SNAPSHOT_DIR..."

# Snapshots sortieren und alle außer den letzten löschen
snapshots=($(ls -1 "$SNAPSHOT_DIR" | sort -V)) # Sortiere alphabetisch oder numerisch
num_snapshots=${#snapshots[@]}

if [[ $num_snapshots -le 1 ]]; then
  echo "Nothing to delete. There is only one or no snapshot."
  exit 0
fi

# Alle bis auf den letzten Snapshot löschen
for ((i = 0; i < num_snapshots - 1; i++)); do
  snapshot="${SNAPSHOT_DIR}/${snapshots[$i]}"
  if [[ -d "$snapshot" ]]; then
    echo "Deleting snapshot: $snapshot"
    if btrfs subvolume show "$snapshot" &>/dev/null; then
      btrfs subvolume delete "$snapshot" || { echo "Error deleting snapshot: $snapshot"; exit 1; }
    else
      rm -rf "$snapshot" || { echo "Error deleting directory: $snapshot"; exit 1; }
    fi
  fi
done

echo "All snapshots except the last one have been deleted."
