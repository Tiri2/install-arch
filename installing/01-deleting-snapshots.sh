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
    echo "Deleting directory: $snapshot"
    rm -rf "$snapshot" || { echo "Error deleting directory $snapshot"; exit 1; }
  fi
done

echo "Deletion completed."
