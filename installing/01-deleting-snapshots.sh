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

for snapshot in "$SNAPSHOT_DIR"/*; do
  if [[ -d "$snapshot" ]]; then
    # Check if it is a subvolume
    btrfs subvolume show "$snapshot" &>/dev/null
    if [[ $? -eq 0 ]]; then
      echo "Deleting subvolume: $snapshot"
      btrfs subvolume delete "$snapshot" || { echo "Error deleting subvolume $snapshot"; exit 1; }
    else
      echo "Skipping (not a subvolume): $snapshot"
    fi
  fi
done

echo "Deletion completed."
