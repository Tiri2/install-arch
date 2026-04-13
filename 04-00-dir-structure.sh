#!/bin/bash

# Following directory structure will be created
mkdir -p /var/system
mkdir -p /var/system/tools
mkdir -p /var/system/scripts
mkdir -p /var/system/certs
mkdir -p /var/system/backup

chmod 775 /var/system
chmod 775 /var/system/*

# to follow the old structure
mkdir -p /var/flex/
ln -sf /var/log/tasks /var/flex/log

ln -sf /srv/smb/share /var/flex/share
ln -sf /srv/smb/customer /var/flex/customer

ln -sf /srv/http /var/flex/http
ln -sf /srv/tasks/CURRENT/data /var/flex/tasks

ln -sf /var/system/certs /var/flex/.certs
ln -sf /var/system /var/flex/system
ln -sf /var/system/config.json /var/flex/config.json

# Create under directories in srv
mkdir -p /srv/{tasks,http,smb}
chmod 777 /srv/tasks
chmod 775 /srv/http
chmod 777 /srv/smb

# Creating specifc smb folders
ln -sf /var/system/backup /srv/smb/backup

chmod 775 /srv/smb/*

# Creating tasks specifc folders
mkdir -p /srv/tasks/CORE-2.0.0-SNAPSHOT/
ln -sf /srv/tasks/CORE-2.0.0-SNAPSHOT/ /srv/tasks/CURRENT

mkdir -p /srv/tasks/CURRENT/{default,lib}
ln -sf /var/system/certs/ /srv/tasks/CURRENT/default/certs
ln -sf /srv/tasks/CURRENT/lib/ /srv/tasks/CURRENT/default/lib
mkdir -p /srv/tasks/CURRENT/data/default/db

echo "File Structure created"
echo "Next Script will be 04-01-init-tasks.sh"