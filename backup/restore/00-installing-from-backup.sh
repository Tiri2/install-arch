#!/bin/bash

IP=10.1.1.70

echo "======          Industruction             ======"
echo " "
echo " "
echo "These scripts writes a backup on the hard disk of this device. "
echo "If you want to install from the master use a other script instead of this."
echo " "

# TODO: System gehört formatiert - einfach die installations Schritte befolgen. anstatt aber pacstrap installieren gehören die einzelne subvolumes eingespielt.

# Befehl zum einspielen: "unzstd <volume>.zst | btrfs receive /<volume>"