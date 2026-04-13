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

cd /var/flex

ln -sf /var/log/tasks log

ln -sf /srv/smb/share share
ln -sf /srv/smb/customer customer

ln -sf /srv/http http
ln -sf /srv/tasks/CURRENT/data tasks

ln -sf /var/system/certs .certs
ln -sf /var/system .system
ln -sf /var/system/config.json config.json

# Create under directories in srv
mkdir -p /srv/{tasks,http,smb}
chmod 777 /srv/tasks
chmod 775 /srv/http
chmod 777 /srv/smb

# Creating specifc smb folders
cd /srv/smb/
ln -sf /var/system/backup backup

chmod 775 /srv/smb/*

# Creating tasks specifc folders
cd /srv/tasks/
mkdir -p CORE-2.0.0-SNAPSHOT/
ln -sf CORE-2.0.0-SNAPSHOT/ CURRENT

mkdir -p ./CURRENT/{default,lib}
cd ./CURRENT/default
ln -sf /var/system/certs/ certs
ln -sf /srv/tasks/CURRENT/lib/ lib

mkdir -p /srv/tasks/CURRENT/data/default/db

echo "File Structure created"
echo "Next Script will be 04-01-init-tasks.sh"