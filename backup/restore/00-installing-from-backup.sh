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

# Format the hard disk
echo "executing 01-partitioning.sh"
source ../../01-partitioning.sh

echo "executing 02-1-format.sh"
source ../../02-1-format.sh

echo "BTRFS -> $BTRFS"

# TODO den tar datei angeben und diese dann extrahieren und die einzelnen subvolumes dann via btrfs receive einspielen